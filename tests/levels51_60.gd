extends SceneTree

const EXPECTED_TYPES := {
	51: ["moving", "orbital"],
	52: ["falling", "retractable"],
	53: ["impulse"],
	54: ["retractable", "temporary"],
	55: ["orbital", "wind"],
	56: ["impulse", "laser"],
	57: ["moving", "orbital", "retractable"],
	58: ["falling", "impulse", "orbital"],
	59: ["impulse", "retractable", "temporary"],
	60: ["impulse", "orbital", "retractable"],
}

const SCRIPT_TYPES := {
	"res://scripts/obstacles/retractable_spikes.gd": "retractable",
	"res://scripts/obstacles/orbital_saw.gd": "orbital",
	"res://scripts/platforms/impulse_platform.gd": "impulse",
	"res://scripts/platforms/moving_platform.gd": "moving",
	"res://scripts/platforms/falling_platform.gd": "falling",
	"res://scripts/platforms/temporary_platform.gd": "temporary",
	"res://scripts/obstacles/wind_field.gd": "wind",
	"res://scripts/obstacles/intermittent_laser.gd": "laser",
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

	for number in range(51, 61):
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
			var script_path := String(child.get_script().resource_path) if child.get_script() != null else ""
			if SCRIPT_TYPES.has(script_path):
				var type_name: String = SCRIPT_TYPES[script_path]
				if not found_types.has(type_name):
					found_types.append(type_name)
			var child_2d := child as Node2D
			if script_path == "res://scripts/obstacles/retractable_spikes.gd":
				var nearest_platform := Vector2.ZERO
				var nearest_distance := INF
				for platform_position in level.platform_positions:
					var distance: float = absf(platform_position.y - (child_2d.position.y + 24.0))
					if distance < nearest_distance:
						nearest_distance = distance
						nearest_platform = platform_position
				var left_clear: float = (child_2d.position.x - 28.0) - (nearest_platform.x - 50.0)
				var right_clear: float = (nearest_platform.x + 50.0) - (child_2d.position.x + 28.0)
				check(nearest_distance <= 1.0 and maxf(left_clear, right_clear) >= 45.0, "Espinho retrátil da fase %d preserva passagem" % number)
			elif script_path == "res://scripts/obstacles/orbital_saw.gd":
				var pivot: Vector2 = child.get("_pivot")
				var radius: float = float(child.get("orbit_radius"))
				check(pivot.x - radius - 20.0 >= 15.0 and pivot.x + radius + 20.0 <= 345.0, "Órbita da fase %d permanece dentro da tela" % number)
			elif script_path == "res://scripts/platforms/impulse_platform.gd":
				var platform_index := _platform_index(level.platform_positions, child_2d.position)
				check(platform_index >= 0 and level.disabled_platform_indices.has(platform_index), "Impulso da fase %d substitui plataforma fixa" % number)
				if platform_index >= 0 and platform_index + 1 < level.platform_positions.size():
					var travel_x: float = level.platform_positions[platform_index + 1].x - child_2d.position.x
					check(travel_x * int(child.get("direction")) > 0.0 and absf(travel_x) <= 130.0, "Impulso da fase %d aponta para o próximo pouso" % number)

		for disabled_index in level.disabled_platform_indices:
			var platform_name: String = str(level.PLATFORM_NAMES[disabled_index])
			var disabled_platform := main.get_node(platform_name) as StaticBody2D
			check(not disabled_platform.visible and disabled_platform.collision_layer == 0, "Substituição %d da fase %d remove plataforma fixa" % [disabled_index + 1, number])
			var replacement_found := false
			for child in level.get_children():
				if child is Node2D:
					var path := String(child.get_script().resource_path) if child.get_script() != null else ""
					var replacement_position: Vector2 = child.position
					if path == "res://scripts/platforms/moving_platform.gd":
						replacement_position = child.get("_origin")
					if replacement_position.is_equal_approx(level.platform_positions[disabled_index]):
						replacement_found = replacement_found or SCRIPT_TYPES.has(path)
			check(replacement_found, "Fase %d possui substituta na posição %d" % [number, disabled_index + 1])

		found_types.sort()
		var expected: Array = EXPECTED_TYPES[number].duplicate()
		expected.sort()
		check(found_types == expected, "Fase %d usa somente %s" % [number, ", ".join(expected)])
		check(found_types.size() >= 1 and found_types.size() <= 3, "Fase %d usa entre um e três tipos" % number)
		main.restart_attempt()
		check(main._attempt_active and main.player.visible, "Restart funcional na fase %d" % number)

	print("FASES 51-60: alcance, substituições e variedade. Falhas: ", failures.size())
	quit(0 if failures.is_empty() else 1)

func _platform_index(positions: PackedVector2Array, target: Vector2) -> int:
	for index in range(positions.size()):
		if positions[index].is_equal_approx(target):
			return index
	return -1
