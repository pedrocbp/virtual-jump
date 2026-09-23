extends SceneTree

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
	for frame in range(4):
		await process_frame

func _capture(name: String) -> void:
	if not captures:
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://build/qa17/" + name + ".png")

func _touch(index: int, point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = point
	event.pressed = pressed
	Input.parse_input_event(event)

func _run() -> void:
	root.get_node("SaveManager").set_script(load("res://tests/memory_save.gd"))
	captures = DisplayServer.get_name() != "headless"
	if captures:
		DirAccess.make_dir_recursive_absolute("res://build/qa17")
	await _open("res://scenes/ui/MainMenu.tscn")
	await _capture("menu")
	await _open("res://scenes/ui/LevelSelect.tscn")
	await _capture("levels")
	if captures:
		root.size = Vector2i(360, 800)
		await _open("res://scenes/ui/MainMenu.tscn")
		await _capture("menu_tall")
		root.size = Vector2i(480, 720)
		await _open("res://scenes/ui/LevelSelect.tscn")
		await _capture("levels_wide")
		root.size = Vector2i(360, 640)
	for number in range(1, 31):
		await _open("res://scenes/levels/Level%02d.tscn" % number)
		var main = current_scene.get_node("Main")
		check(main != null and main.ui != null, "HUD da fase %d" % number)
		check(main.player.gravity == 1200 and main.player.jump_force == 500, "Física preservada")
		check(main.player.get_node("CollisionShape2D").shape.radius == 16, "Raio preservado")
		check(main.player.get_node_or_null("Trail") != null, "Rastro visual presente")
		check(main.get_node("Floor/Visual/Skin") != null, "Visual da fase %d" % number)
		if number in [6, 7, 8, 9, 21, 22, 23, 24, 25, 27, 28, 29, 30]:
			await _capture("hazard_%02d" % number)
		if number == 1:
			_touch(0, Vector2(30, 400), true)
			await process_frame
			check(main.player._get_horizontal_input() == -1, "Touch esquerdo chega ao jogador")
			_touch(1, Vector2(300, 400), true)
			await process_frame
			check(main.player._get_horizontal_input() == 0, "Multitouch se anula")
			_touch(0, Vector2(30, 400), false)
			await process_frame
			check(main.player._get_horizontal_input() == 1, "Touch direito permanece")
			_touch(1, Vector2(300, 400), false)
			await process_frame
			check(main.player._touches.is_empty(), "Soltar limpa o touch")
			if captures:
				for pressed in [true, false]:
					var click := InputEventMouseButton.new()
					click.button_index = MOUSE_BUTTON_LEFT
					click.position = Vector2(310, 50)
					click.pressed = pressed
					Input.parse_input_event(click)
					await process_frame
			else:
				# O servidor headless não possui seleção de GUI; valida a mesma ação diretamente.
				main.toggle_pause()
			check(paused and main.ui.pause_menu.visible, "Botão da HUD abre pausa")
			check(main.player._touches.is_empty(), "Botão da HUD não movimenta a bolinha")
			if paused:
				main.toggle_pause()
		if number == 30:
			await _capture("game")
			main.toggle_pause()
			var time_before = main._elapsed_seconds
			var position_before = main.player.position
			await create_timer(0.1).timeout
			check(main._elapsed_seconds == time_before and main.player.position == position_before, "Pausa congela timer e corpo")
			await _capture("pause")
			main.toggle_pause()
			main._die()
			check(main._dying and not main._attempt_active and main.player.visible and main.player.death_animating, "Animação de morte")
			await create_timer(0.35).timeout
			check(main._attempt_active and main.player.visible and not main._dying, "Reinício após morte")
			main._elapsed_seconds = 12.34
			main._on_goal_reached(main.player)
			check(main._completed and not main._attempt_active and not main.player.is_physics_processing(), "Conclusão congela tentativa")
			await create_timer(0.3).timeout
			await _capture("result")
			main.restart_attempt()
			check(main._elapsed_seconds == 0 and not main._completed, "Repetir conclusão")
		main.restart_attempt()
		for object in get_nodes_in_group("attempt_resettable"):
			var script_path: String = object.get_script().resource_path
			if "moving_" in script_path:
				check(object.position.is_equal_approx(object._origin), "Posição inicial restaurada")
			if "temporary_" in script_path:
				check(object._is_active, "Objeto temporário ativo ao reiniciar")
			if "breakable_platform" in script_path:
				check(object._state == "stable", "Quebrável restaurada")
	var feedback := root.get_node("Feedback")
	feedback.toggle_sound()
	check(feedback.muted and feedback._music.stream_paused, "Silenciar áudio")
	feedback.toggle_sound()
	feedback.change_scene("res://scenes/ui/MainMenu.tscn")
	await create_timer(0.6).timeout
	check(not feedback.transitioning and not paused and current_scene.name == "MainMenu", "Transição libera entrada e pausa")
	feedback._music.stop()
	for voice in feedback._voices:
		voice.stop()
	await create_timer(0.15).timeout
	print("PHASE17: 30 cenas, pausa, morte, reinício, conclusão, áudio e transição. Falhas: ", failures.size())
	quit(0 if failures.is_empty() else 1)
