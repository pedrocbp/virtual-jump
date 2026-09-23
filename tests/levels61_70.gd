extends SceneTree

const EXPECTED_TYPES := {
	61: ["current"], 62: ["current"], 63: ["portal"], 64: ["portal"],
	65: ["current", "impulse"], 66: ["portal", "retractable"],
	67: ["orbital", "portal"], 68: ["current", "laser"],
	69: ["current", "portal", "temporary"],
	70: ["current", "portal", "retractable"],
}

const SCRIPT_TYPES := {
	"res://scripts/obstacles/vertical_current.gd": "current",
	"res://scripts/obstacles/portal.gd": "portal",
	"res://scripts/platforms/impulse_platform.gd": "impulse",
	"res://scripts/obstacles/retractable_spikes.gd": "retractable",
	"res://scripts/obstacles/orbital_saw.gd": "orbital",
	"res://scripts/obstacles/intermittent_laser.gd": "laser",
	"res://scripts/platforms/temporary_platform.gd": "temporary",
}

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _open_level(number: int) -> void:
	paused = false
	check(change_scene_to_file("res://scenes/levels/Level%02d.tscn" % number) == OK, "Abrir fase %d" % number)
	for _frame in range(5):
		await process_frame

func _run() -> void:
	var save := root.get_node_or_null("SaveManager")
	if save != null:
		save.set_script(load("res://tests/memory_save.gd"))

	for number in range(61, 71):
		await _open_level(number)
		var level = current_scene
		var main = level.get_node("Main")
		check(main.level_config.level_number == number, "Configuração da fase %d" % number)
		check(level.platform_positions.size() == 10, "Fase %d possui dez plataformas" % number)
		for index in range(1, level.platform_positions.size()):
			var previous: Vector2 = level.platform_positions[index - 1]
			var current: Vector2 = level.platform_positions[index]
			check(previous.y - current.y >= 80.0 and previous.y - current.y <= 90.0, "Altura alcançável %d→%d na fase %d" % [index, index + 1, number])
			check(absf(previous.x - current.x) <= 130.0, "Distância horizontal alcançável %d→%d na fase %d" % [index, index + 1, number])

		var found_types: Array[String] = []
		for child in level.get_children():
			var path := String(child.get_script().resource_path) if child.get_script() != null else ""
			if SCRIPT_TYPES.has(path):
				var type_name: String = SCRIPT_TYPES[path]
				if not found_types.has(type_name):
					found_types.append(type_name)
			var child_2d := child as Node2D
			if path == "res://scripts/obstacles/portal.gd" and bool(child.get("active")):
				var target := child.get_node_or_null(child.get("target_path")) as Node2D
				check(target != null, "Portal ativo da fase %d possui saída" % number)
				if target != null:
					check(target.position.y <= child_2d.position.y - 150.0, "Portal da fase %d transporta para cima" % number)
			elif path == "res://scripts/obstacles/vertical_current.gd":
				check(child.call("push_at", child_2d.global_position) != 0.0, "Corrente da fase %d atua dentro da área" % number)
				check(is_zero_approx(float(child.call("push_at", Vector2(-500, -500)))), "Corrente da fase %d não atua fora da área" % number)
			elif path == "res://scripts/obstacles/retractable_spikes.gd":
				var nearest_platform := Vector2.ZERO
				var nearest_distance := INF
				for platform_position in level.platform_positions:
					var distance: float = absf(platform_position.y - (child_2d.position.y + 24.0))
					if distance < nearest_distance:
						nearest_distance = distance
						nearest_platform = platform_position
				var left_clear: float = (child_2d.position.x - 28.0) - (nearest_platform.x - 50.0)
				var right_clear: float = (nearest_platform.x + 50.0) - (child_2d.position.x + 28.0)
				check(nearest_distance <= 1.0 and maxf(left_clear, right_clear) >= 45.0, "Espinho da fase %d preserva passagem" % number)
			elif path == "res://scripts/obstacles/orbital_saw.gd":
				var pivot: Vector2 = child.get("_pivot")
				var radius: float = float(child.get("orbit_radius"))
				check(pivot.x - radius - 20.0 >= 15.0 and pivot.x + radius + 20.0 <= 345.0, "Órbita da fase %d permanece dentro da tela" % number)
			elif path == "res://scripts/platforms/impulse_platform.gd":
				var platform_index := _platform_index(level.platform_positions, child_2d.position)
				check(platform_index >= 0 and level.disabled_platform_indices.has(platform_index), "Impulso da fase %d substitui plataforma" % number)
				if platform_index >= 0 and platform_index + 1 < level.platform_positions.size():
					var travel_x: float = level.platform_positions[platform_index + 1].x - child_2d.position.x
					check(travel_x * int(child.get("direction")) > 0.0, "Impulso da fase %d aponta para o próximo pouso" % number)

		found_types.sort()
		var expected: Array = EXPECTED_TYPES[number].duplicate()
		expected.sort()
		check(found_types == expected, "Fase %d usa somente %s" % [number, ", ".join(expected)])
		check(found_types.size() >= 1 and found_types.size() <= 3, "Fase %d usa entre um e três tipos" % number)
		main.restart_attempt()
		check(main._attempt_active and main.player.visible, "Restart funcional na fase %d" % number)

	await _open_level(61)
	var upward_current: Node = current_scene.get_node("VerticalCurrent1")
	check(float(upward_current.call("push_at", upward_current.global_position)) < -1200.0, "Corrente ascendente aplica força suficiente")
	var current_player: Node = current_scene.get_node("Main/Player")
	current_player.global_position = upward_current.global_position
	current_player.velocity = Vector2.ZERO
	var pushed_up := false
	for _frame in range(4):
		await physics_frame
		pushed_up = pushed_up or current_player.velocity.y < 0.0
	check(pushed_up, "Corrente ascendente altera a trajetória da bolinha")

	await _open_level(62)
	var downward_current: Node2D = current_scene.get_node("VerticalCurrentDown") as Node2D
	var downward_size: Vector2 = downward_current.get("zone_size")
	var downward_top: float = downward_current.position.y - downward_size.y * 0.5
	check(downward_top >= 425.0, "Corrente descendente não bloqueia o salto da segunda para a terceira plataforma")
	check(float(downward_current.get("strength")) <= 320.0, "Corrente descendente mantém força compensável")

	await _open_level(63)
	var portal: Node = current_scene.get_node("PortalEntry1")
	var portal_exit: Node2D = current_scene.get_node("PortalExit1") as Node2D
	var portal_player: Node = current_scene.get_node("Main/Player")
	portal_player.set_physics_process(false)
	portal_player.global_position = portal.global_position
	portal_player.velocity = Vector2(0, 100)
	portal.call("_on_body_entered", portal_player)
	check(portal_player.global_position.is_equal_approx(portal_exit.global_position), "Portal transporta a bolinha para a saída")
	check(portal_player.velocity.y <= -240.0, "Portal devolve impulso vertical para continuar")

	print("FASES 61-70: alcance, portais e correntes verticais. Falhas: ", failures.size())
	quit(0 if failures.is_empty() else 1)

func _platform_index(positions: PackedVector2Array, target: Vector2) -> int:
	for index in range(positions.size()):
		if positions[index].is_equal_approx(target):
			return index
	return -1
