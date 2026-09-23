extends SceneTree

const REQUIRED_CLIMB := 348.0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if change_scene_to_file("res://scenes/endless/Endless.tscn") != OK:
		_fail("Não foi possível abrir o modo infinito")
		return
	for _frame in range(5):
		await process_frame
	var endless := current_scene
	endless._generate_until(-3000.0)
	await process_frame
	var player := endless.player as Player
	var spring: SpringPlatform
	var target_platform: Node2D
	for generated: Node in endless._generated:
		if generated is SpringPlatform:
			spring = generated
			break
	if spring == null:
		_fail("A rota inicial não gerou uma plataforma de mola")
		return
	var spring_index := int(spring.get_meta("endless_index"))
	for generated: Node in endless._generated:
		if generated is Node2D and int(generated.get_meta("endless_index", -1)) == spring_index + 1:
			target_platform = generated as Node2D
			break
	if target_platform == null:
		_fail("A mola não possui uma plataforma de destino")
		return
	player.set_physics_process(false)
	# Fora do corredor de plataformas para medir somente a física vertical,
	# sem bater na parte inferior de uma plataforma já gerada.
	player.global_position = Vector2(-1000.0, 500.0)
	spring.on_player_landed()
	if player.velocity.y > -1079.0:
		_fail("A mola não aplicou o impulso configurado")
		return
	var start_y := player.global_position.y
	var highest_y := start_y
	player.set_physics_process(true)
	for _frame in range(150):
		await physics_frame
		highest_y = minf(highest_y, player.global_position.y)
		if player.velocity.y >= 0.0:
			break
	var climbed := start_y - highest_y
	if climbed < REQUIRED_CLIMB:
		_fail("Impulso real da mola subiu apenas %.1f px" % climbed)
		return

	# Reproduz a primeira transição real de mola com a mesma correção por toque
	# que o jogador usa: acelera até alinhar e solta perto do destino.
	player.set_physics_process(false)
	player.reset_motion()
	player.global_position = spring.global_position + Vector2(0.0, -27.0)
	spring.on_player_landed()
	player.set_physics_process(true)
	var landed_on_target := false
	for _frame in range(180):
		var delta_x := target_platform.global_position.x - player.global_position.x
		Input.action_release("move_left")
		Input.action_release("move_right")
		if absf(delta_x) > 18.0:
			Input.action_press("move_right" if delta_x > 0.0 else "move_left")
		await physics_frame
		var expected_center_y := target_platform.global_position.y - 26.0
		if player.is_on_floor() and absf(player.global_position.y - expected_center_y) < 4.0:
			landed_on_target = true
			break
	Input.action_release("move_left")
	Input.action_release("move_right")
	if not landed_on_target:
		_fail("A primeira rota de mola não pousou na plataforma seguinte")
		return
	print("SPRING BOOST: OK, subida %.1f px e rota %d→%d concluída" % [climbed, spring_index, spring_index + 1])
	quit()

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
