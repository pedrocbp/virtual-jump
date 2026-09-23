extends SceneTree

const Catalog := preload("res://scripts/systems/level_catalog.gd")

var failures: Array[String] = []
var captures := false

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _open(path: String) -> void:
	paused = false
	check(change_scene_to_file(path) == OK, "Abrir " + path)
	for i in range(5):
		await process_frame

func _capture(name: String) -> void:
	if captures:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://build/qa18/" + name + ".png")

func _run() -> void:
	var save := root.get_node("SaveManager")
	save.set_script(load("res://tests/memory_save.gd"))
	var feedback := root.get_node("Feedback")
	save._restore({})
	feedback.apply_settings()
	captures = DisplayServer.get_name() != "headless"
	DirAccess.make_dir_recursive_absolute("res://build/qa18")
	# Arquivo isolado: valida gravação/leitura real sem tocar no save do jogador.
	save._restore({"highest_unlocked_level": 31, "completed_levels": [1, 30], "best_times": {"1": 12.5}, "best_medals": {"1": 3}})
	check(save.highest_unlocked_level == 31 and save.settings.music_enabled, "Migração preserva progresso e aplica defaults")
	save.set_setting("music_volume", 0.37)
	save.set_setting("vibration_enabled", false)
	save.set_setting("visual_theme", 2)
	check(root.get_node("VisualTheme").visible and root.get_node("VisualTheme").get_selected_theme() == 2, "Tema minimalista claro aplicado imediatamente")
	check(save._write_save("res://build/qa18/test_save.json"), "Gravação isolada")
	save.set_setting("master_volume", 0.72)
	check(save._write_save("res://build/qa18/test_save.json"), "Substituição atômica do save")
	var restored = load("res://scripts/systems/save_manager.gd").new()
	restored._restore(JSON.parse_string(FileAccess.get_file_as_string("res://build/qa18/test_save.json")))
	check(is_equal_approx(restored.settings.music_volume, 0.37) and not restored.settings.vibration_enabled and restored.settings.visual_theme == 2 and restored.highest_unlocked_level == 31, "Preferências, tema e progresso persistem")
	restored._restore({"completed_levels": "inválido", "settings": {"music_volume": -4, "sfx_volume": "inválido", "music_enabled": "false"}})
	check(restored.completed_levels.is_empty() and restored.settings.music_volume == 0 and restored.settings.sfx_volume == 1 and restored.settings.music_enabled, "Campos inválidos tolerados")
	restored.free()
	save.set_setting("visual_theme", 0)
	save.set_setting("music_enabled", false)
	check(feedback._music.stream_paused, "Desativar música")
	save.set_setting("music_enabled", true)
	save.set_setting("sfx_enabled", false)
	var voice_before = feedback._voice_index
	feedback.play_sound("win")
	check(feedback._voice_index == voice_before, "Efeito desligado não toca")
	save.set_setting("sfx_enabled", true)
	await _open("res://scenes/ui/MainMenu.tscn")
	feedback.open_settings()
	await process_frame
	var settings = feedback.settings_panel
	check(paused, "Configurações bloqueiam a partida")
	await _capture("settings")
	save.set_setting("visual_theme", 1)
	await process_frame
	await _capture("settings_theme_dark")
	save.set_setting("visual_theme", 2)
	await process_frame
	await _capture("settings_theme_light")
	save.set_setting("visual_theme", 0)
	await process_frame
	settings._ask_reset()
	await _capture("confirmation")
	settings.go_back()
	check(not settings._confirmation.visible and save.highest_unlocked_level == 31, "Cancelar preserva progresso")
	settings.go_back()
	await process_frame
	check(not paused, "Voltar do menu restaura pausa")
	await _open("res://scenes/levels/Level31.tscn")
	var main = current_scene.get_node("Main")
	main.toggle_pause()
	feedback.open_settings()
	await process_frame
	feedback.settings_panel.go_back()
	await process_frame
	check(paused and main.ui.pause_menu.visible, "Configurações da pausa não retomam a fase")
	main.toggle_pause()
	for number in range(1, Catalog.TOTAL_LEVELS + 1):
		await _open("res://scenes/levels/Level%02d.tscn" % number)
		main = current_scene.get_node("Main")
		check(main.level_config.level_number == number and main.ui != null, "Fase %d" % number)
		if number in [31, 32, 33, 35, 38, 39, 40]:
			await _capture("level_%d" % number)
		if number == 35:
			save.set_setting("visual_theme", 1)
			await process_frame
			await _capture("level_35_theme_dark")
			save.set_setting("visual_theme", 2)
			await process_frame
			await _capture("level_35_theme_light")
			save.set_setting("visual_theme", 0)
			await process_frame
		if number == 31:
			var wind = get_nodes_in_group("wind_fields")[0]
			check(wind.push_at(wind.global_position) > 0 and wind.push_at(Vector2(-500, -500)) == 0, "Vento limitado à área")
			main.player.position = wind.position
			main.player.velocity = Vector2.ZERO
			await physics_frame
			await physics_frame
			check(main.player.velocity.x > 0, "Vento desloca jogador sem entrada")
			Input.action_press("move_left")
			var compensated := false
			for frame in range(14):
				await physics_frame
				compensated = compensated or main.player.velocity.x < -1
			check(compensated, "Direção contrária compensa vento")
			Input.action_release("move_left")
		if number == 32:
			var laser = get_nodes_in_group("hazards")[0]
			laser.reset_attempt()
			laser._physics_process(laser.inactive_duration + 0.01)
			check(laser.state == "warning", "Laser avisa antes de ligar")
			laser._physics_process(laser.warning_duration)
			check(laser.state == "active", "Laser liga após aviso")
			laser._physics_process(laser.active_duration)
			check(laser.state == "off", "Laser desliga no ciclo")
			laser.reset_attempt()
			main.player.set_physics_process(false)
			main.player.position = laser.position
			for frame in range(4):
				await physics_frame
			check(not main._dying, "Laser desligado permite passagem")
			laser._elapsed = laser.inactive_duration + laser.warning_duration
			laser._physics_process(0.01)
			check(main._dying, "Laser ligado mata jogador já dentro da área")
			await create_timer(0.3).timeout
		if number == 33:
			var platform = get_nodes_in_group("attempt_resettable")[0]
			main.player.reset_motion()
			main.player.position = platform.position + Vector2(0, -35)
			main.player.velocity.y = 100
			for frame in range(10):
				await physics_frame
			check(platform.state == "shaking", "Pouso real dispara plataforma")
			main.player.set_physics_process(false)
			platform.reset_attempt()
			await process_frame
			check(platform.visible and platform.position == platform._origin and not platform.get_node("CollisionShape2D").disabled, "Reset restaura visibilidade da plataforma")
			platform.on_player_landed()
			platform._physics_process(0.2)
			check(platform.state == "shaking" and platform.position == platform._origin, "Plataforma treme sem mover colisão")
			platform._physics_process(0.21)
			check(platform.state == "falling", "Plataforma cai após 0,4 s")
			for frame in range(12):
				await physics_frame
			check(platform.position.y > platform._origin.y, "Queda move corpo")
			platform.reset_attempt()
			check(platform.position == platform._origin and platform.state == "stable", "Queda restaurada no restart")
		main.restart_attempt()
	save.record_completion(30, 12, 3)
	check(save.is_level_unlocked(31), "Fase 30 libera 31")
	save.record_completion(Catalog.TOTAL_LEVELS, 12, 3)
	check(save.highest_unlocked_level == Catalog.TOTAL_LEVELS, "Limite de %d fases" % Catalog.TOTAL_LEVELS)
	main = current_scene.get_node("Main")
	main.toggle_pause()
	feedback.open_settings()
	await process_frame
	settings = feedback.settings_panel
	settings._ask_reset()
	settings._confirm_reset()
	await create_timer(0.6).timeout
	check(save.highest_unlocked_level == 1 and save.completed_levels.is_empty() and save.best_times.is_empty() and save.best_medals.is_empty(), "Reset confirmado apaga somente progresso fictício")
	check(is_equal_approx(save.settings.music_volume, 0.37) and not save.settings.vibration_enabled, "Reset mantém preferências")
	check(current_scene.name == "MainMenu" and not paused, "Reset retorna ao menu")
	feedback._music.stop()
	for voice in feedback._voices:
		voice.stop()
	await create_timer(0.15).timeout
	print("PHASE18 + LEVELS31-%d: falhas = %d" % [Catalog.TOTAL_LEVELS, failures.size()])
	quit(0 if failures.is_empty() else 1)
