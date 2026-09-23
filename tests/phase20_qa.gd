extends SceneTree

const Catalog := preload("res://scripts/systems/level_catalog.gd")

## Smoke test da Fase 20: carrega todas as fases em tamanhos de tela comuns
## e verifica os pontos que mais causaram regressões durante o desenvolvimento.

var failures: Array[String] = []
var sizes := [Vector2i(360, 640), Vector2i(360, 800), Vector2i(480, 720)]

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _open(path: String) -> void:
	paused = false
	check(change_scene_to_file(path) == OK, "Abrir " + path)
	for _frame in range(4):
		await process_frame

func _check_level(number: int) -> void:
	var main := current_scene.get_node_or_null("Main")
	check(main != null, "Fase %d sem Main" % number)
	if main == null:
		return
	check(main.level_config != null and main.level_config.level_number == number, "Configuração da fase %d" % number)
	check(main.player != null and main.player.get_node_or_null("CollisionShape2D") != null, "Jogador da fase %d" % number)
	check(main.camera != null, "Câmera da fase %d" % number)
	check(main.ui != null, "HUD da fase %d" % number)
	check(main.get_node_or_null("Goal") != null, "Chegada da fase %d" % number)
	check(main.get_node_or_null("Floor") != null, "Área de queda da fase %d" % number)
	# Ações essenciais precisam existir em todas as fases.
	check(InputMap.has_action("move_left") and InputMap.has_action("move_right"), "Input horizontal da fase %d" % number)
	check(InputMap.has_action("restart"), "Input de restart da fase %d" % number)
	# O restart deve devolver o jogador a uma posição válida e reativar a tentativa.
	main.restart_attempt()
	await process_frame
	check(main._attempt_active and not main._completed and not main._dying, "Restart da fase %d" % number)
	check(main.player.visible and main.player.position.is_finite(), "Posição do jogador após restart na fase %d" % number)
	if number == 6:
		var spike_two := current_scene.get_node_or_null("SpikeTwo") as Area2D
		var spike_platform := main.get_node_or_null("PlatformSeven") as StaticBody2D
		check(spike_two != null and spike_platform != null, "Fase 6 possui segundo espinho e plataforma")
		if spike_two != null and spike_platform != null:
			var clear_landing_width := (spike_two.position.x - 15.0) - (spike_platform.position.x - 50.0)
			check(clear_landing_width >= 55.0, "Segundo espinho da fase 6 preserva corredor de pouso à esquerda")
	if number == 26:
		var lower_spike := current_scene.get_node_or_null("SpikeLower") as Area2D
		var lower_platform := main.get_node_or_null("PlatformFour") as StaticBody2D
		check(lower_spike != null and lower_platform != null, "Fase 26 possui primeiro espinho e plataforma")
		if lower_spike != null and lower_platform != null:
			var clear_right_width := (lower_platform.position.x + 50.0) - (lower_spike.position.x + 15.0)
			check(clear_right_width >= 50.0, "Primeiro espinho da fase 26 preserva passagem à direita")

func _run() -> void:
	var save := root.get_node_or_null("SaveManager")
	check(save != null, "SaveManager ausente")
	if save != null:
		save.set_script(load("res://tests/memory_save.gd"))

	for size in sizes:
		root.size = size
		await _open("res://scenes/ui/MainMenu.tscn")
		check(current_scene.name == "MainMenu", "Menu não abriu em %s" % size)
		var progress_caption := current_scene.find_child("ProgressCaption", true, false) as Label
		var hero_backdrop := current_scene.find_child("HeroBackdrop", true, false) as Control
		var hero_title := current_scene.find_child("HeroTitle", true, false) as Label
		var hero_subtitle := current_scene.find_child("HeroSubtitle", true, false) as Label
		var settings_button := current_scene.find_child("SettingsButton", true, false) as Button
		check(hero_backdrop != null and hero_title != null and hero_subtitle != null, "Menu possui arte e textos responsivos em %s" % size)
		if hero_backdrop != null and hero_title != null:
			var artwork_bottom := hero_backdrop.global_position.y + float(hero_backdrop.get("hero_center_y")) + 85.0
			check(hero_title.global_position.y >= artwork_bottom, "Título do menu não cobre os objetos decorativos em %s" % size)
		if hero_title != null and hero_subtitle != null:
			check(hero_subtitle.global_position.y >= hero_title.global_position.y + hero_title.size.y, "Subtítulo do menu não cobre o título em %s" % size)
		check(settings_button != null and settings_button.size.y <= 44.5, "Configurações usa botão compacto em %s" % size)
		for button_name in ["LevelsButton", "EndlessButton", "SkinsButton", "StatisticsButton"]:
			var compact_button := current_scene.find_child(button_name, true, false) as Button
			check(compact_button != null, "Menu possui %s em %s" % [button_name, size])
			if compact_button != null:
				check(compact_button.size.y <= 44.5, "%s permanece minimalista em %s" % [button_name, size])
		check(progress_caption != null, "Menu possui indicador de fases em %s" % size)
		if progress_caption != null:
			var caption_end := progress_caption.global_position + progress_caption.size
			check(progress_caption.global_position.x >= 0.0 and caption_end.x <= float(size.x), "Indicador de fases não corta horizontalmente em %s" % size)
			check(progress_caption.global_position.y >= 0.0 and caption_end.y <= float(size.y), "Indicador de fases fica visível em %s" % size)
		await _open("res://scenes/ui/Skins.tscn")
		check(current_scene.name == "Skins", "Tela de skins não abriu em %s" % size)
		check(current_scene.get_script() != null, "Tela de skins carregou seu controlador em %s" % size)
		check(save.get_unlocked_skin_count() >= 1, "Skin clássica disponível em %s" % size)
		await _open("res://scenes/tutorial/Tutorial.tscn")
		var tutorial_header := current_scene.find_child("TutorialHeader", true, false) as Control
		check(tutorial_header != null, "Tutorial possui cabeçalho responsivo em %s" % size)
		if tutorial_header != null:
			var header_end := tutorial_header.global_position + tutorial_header.size
			check(tutorial_header.global_position.y >= 23.0, "Texto do tutorial respeita margem superior em %s" % size)
			check(tutorial_header.global_position.x >= 0.0 and header_end.x <= float(size.x), "Cabeçalho do tutorial cabe horizontalmente em %s" % size)
			check(header_end.y <= float(size.y) * 0.16, "Cabeçalho do tutorial não cobre a área de jogo em %s" % size)
		await _open("res://scenes/ui/LevelSelect.tscn")
		check(current_scene.name == "LevelSelect", "Seleção não abriu em %s" % size)
		# Em cada resolução, validar as fases de borda; todas as fases são
		# percorridas abaixo na resolução portrait base.
		for number in [1, 25, Catalog.TOTAL_LEVELS]:
			await _open("res://scenes/levels/Level%02d.tscn" % number)
			await _check_level(number)

	root.size = Vector2i(360, 640)
	for number in range(1, Catalog.TOTAL_LEVELS + 1):
		await _open("res://scenes/levels/Level%02d.tscn" % number)
		await _check_level(number)

	await _open("res://scenes/tutorial/Tutorial.tscn")
	var tutorial = current_scene
	check(tutorial != null and tutorial.completion_panel != null, "Tutorial abriu com painel de conclusao")
	if tutorial != null and tutorial.completion_panel != null:
		check(not tutorial.completion_panel.visible, "Botao de comecar fica oculto antes da chegada")
		tutorial._on_goal_reached(tutorial.player)
		check(tutorial.completion_panel.visible, "Botao de comecar aparece depois da chegada")

	await _open("res://scenes/endless/Endless.tscn")
	var endless = current_scene
	check(endless != null, "Modo infinito não abriu")
	if endless != null:
		await physics_frame
		check(endless._generated.size() >= 10, "Modo infinito gerou plataformas suficientes")
		var endless_platforms: Array[Node] = []
		for generated_node: Node in endless._generated:
			if generated_node.has_meta("endless_index"):
				endless_platforms.append(generated_node)
		endless_platforms.sort_custom(func(a: Node, b: Node) -> bool: return int(a.get_meta("endless_index")) < int(b.get_meta("endless_index")))
		for index in range(1, endless_platforms.size()):
			var horizontal_gap: float = absf(endless_platforms[index].position.x - endless_platforms[index - 1].position.x)
			check(horizontal_gap >= 80.0, "Modo infinito sem plataformas consecutivas na mesma coluna: %d" % int(endless_platforms[index].get_meta("endless_index")))
		check("BLOCOS" in endless.ui.time_label.text, "Modo infinito mostra altura em blocos, sem cronômetro")
		check(not endless.ui.progress.visible, "Modo infinito não exibe barra de progresso")
		# As mecânicas especiais são introduzidas somente depois da faixa inicial.
		endless._generate_until(-3500.0)
		await process_frame
		var crumbling_script = load("res://scripts/platforms/crumbling_platform.gd")
		var crumbling_platforms: Array[Node] = endless._generated.filter(func(node: Node) -> bool: return node.get_script() == crumbling_script)
		check(not crumbling_platforms.is_empty(), "Modo infinito possui plataformas frageis")
		if not crumbling_platforms.is_empty():
			var crumbling = crumbling_platforms[0]
			crumbling.on_player_landed()
			check(crumbling.state == "cracking" and crumbling.landing_count == 1, "Plataforma fragil avisa no primeiro pouso")
			# Uma colisão duplicada no mesmo frame não pode contar como nova quicada.
			crumbling.on_player_landed()
			check(crumbling.landing_count == 1, "Plataforma fragil ignora colisao duplicada")
			await physics_frame
			crumbling.on_player_landed()
			check(crumbling.state == "cracking" and crumbling.landing_count == 2, "Plataforma fragil resiste ao segundo pouso")
			await physics_frame
			crumbling.on_player_landed()
			check(crumbling.state == "cracking" and crumbling.landing_count == 3, "Plataforma fragil resiste ao terceiro pouso")
			await physics_frame
			crumbling.on_player_landed()
			check(crumbling.state == "falling", "Plataforma fragil cai somente no quarto pouso")
		var spring_script = load("res://scripts/platforms/spring_platform.gd")
		var springs := get_nodes_in_group("attempt_resettable").filter(func(node: Node) -> bool: return node.get_script() == spring_script)
		check(not springs.is_empty(), "Modo infinito possui plataforma com mola")
		if not springs.is_empty():
			var spring = springs[0]
			var landing = endless._generated.filter(func(node: Node) -> bool: return node.has_meta("spring_landing") and bool(node.get_meta("spring_landing"))).front()
			var spring_horizontal_gap: float = absf(landing.position.x - spring.position.x)
			check(spring_horizontal_gap >= 120.0 and spring_horizontal_gap <= 170.0, "Mola possui aterrissagem diagonal sem bloquear a subida")
			check(spring.position.y - landing.position.y >= 276.0, "Mola avanca pelo menos tres blocos de uma vez")
			check(spring.spring_force >= 1000.0, "Mola usa impulso de boost")
			endless.player.velocity.y = 100.0
			spring.on_player_landed()
			check(endless.player.velocity.y <= -spring.spring_force, "Mola aplica salto alto")

	print("FASE20 QA: %d fases, 3 resoluções, menu, HUD, câmera, restart e inputs. Falhas: %d" % [Catalog.TOTAL_LEVELS, failures.size()])
	quit(0 if failures.is_empty() else 1)
