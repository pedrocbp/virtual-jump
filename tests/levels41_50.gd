extends SceneTree

const EXPECTED_TYPES := {
	41: ["retractable"], 42: ["retractable"],
	43: ["orbital"], 44: ["orbital"],
	45: ["impulse"], 46: ["impulse"],
	47: ["retractable", "impulse"],
	48: ["orbital", "impulse"],
	49: ["retractable", "orbital"],
	50: ["retractable", "orbital", "impulse"],
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

	for number in range(41, 51):
		await _open_level(number)
		var level := current_scene
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
			var child_2d := child as Node2D
			var script_path := String(child.get_script().resource_path) if child.get_script() != null else ""
			if script_path == "res://scripts/obstacles/retractable_spikes.gd":
				if not found_types.has("retractable"):
					found_types.append("retractable")
				var nearest_platform := Vector2.ZERO
				var nearest_distance := INF
				for platform_position in level.platform_positions:
					var distance: float = absf(platform_position.y - (child_2d.position.y + 24.0))
					if distance < nearest_distance:
						nearest_distance = distance
						nearest_platform = platform_position
				var left_clear: float = (child_2d.position.x - 28.0) - (nearest_platform.x - 50.0)
				var right_clear: float = (nearest_platform.x + 50.0) - (child_2d.position.x + 28.0)
				check(nearest_distance <= 1.0 and maxf(left_clear, right_clear) >= 45.0, "Espinho retrátil da fase %d preserva lado seguro" % number)
			elif script_path == "res://scripts/obstacles/orbital_saw.gd":
				if not found_types.has("orbital"):
					found_types.append("orbital")
				var pivot: Vector2 = child.get("_pivot")
				var orbit_radius: float = float(child.get("orbit_radius"))
				var left_limit: float = pivot.x - orbit_radius - 20.0
				var right_limit: float = pivot.x + orbit_radius + 20.0
				check(left_limit >= 15.0 and right_limit <= 345.0, "Órbita da fase %d permanece dentro da tela" % number)
			elif script_path == "res://scripts/platforms/impulse_platform.gd":
				if not found_types.has("impulse"):
					found_types.append("impulse")
				var platform_index := -1
				for index in range(level.platform_positions.size()):
					if level.platform_positions[index].is_equal_approx(child_2d.position):
						platform_index = index
						break
				check(platform_index >= 0 and level.disabled_platform_indices.has(platform_index), "Impulso da fase %d substitui plataforma normal" % number)
				if platform_index >= 0 and platform_index + 1 < level.platform_positions.size():
					var travel_x: float = level.platform_positions[platform_index + 1].x - child_2d.position.x
					check(travel_x * int(child.get("direction")) > 0.0 and absf(travel_x) <= 130.0, "Impulso da fase %d aponta para a próxima plataforma" % number)

		found_types.sort()
		var expected: Array = EXPECTED_TYPES[number].duplicate()
		expected.sort()
		check(found_types == expected, "Fase %d usa somente %s" % [number, ", ".join(expected)])
		check(found_types.size() >= 1 and found_types.size() <= 3, "Fase %d usa entre um e três tipos novos" % number)
		main.restart_attempt()
		check(main.player.visible and main._attempt_active, "Restart funcional na fase %d" % number)

	await _open_level(41)
	var retractable: Node = current_scene.get_node("RetractableSpikes1")
	retractable.call("reset_attempt")
	check(String(retractable.get("state")) == "hidden", "Espinhos começam recolhidos")
	retractable.call("_physics_process", float(retractable.get("hidden_duration")) + 0.01)
	check(String(retractable.get("state")) == "warning", "Espinhos avisam antes de subir")
	retractable.call("_physics_process", float(retractable.get("warning_duration")))
	check(String(retractable.get("state")) == "active", "Espinhos sobem após o aviso")
	retractable.call("_physics_process", float(retractable.get("active_duration")))
	check(String(retractable.get("state")) == "hidden", "Espinhos retornam ao estado recolhido")

	await _open_level(43)
	var orbital: Node2D = current_scene.get_node("OrbitalSaw1") as Node2D
	var first_position: Vector2 = orbital.position
	orbital.call("_physics_process", 0.25)
	check(not orbital.position.is_equal_approx(first_position), "Serra orbital percorre trajetória circular")
	orbital.call("reset_attempt")
	check(is_equal_approx(orbital.position.distance_to(orbital.get("_pivot")), float(orbital.get("orbit_radius"))), "Serra orbital reinicia na órbita")

	await _open_level(45)
	var impulse: Node = current_scene.get_node("ImpulsePlatform1")
	var player: Node = current_scene.get_node("Main/Player")
	impulse.call("on_player_landed")
	check(float(player.get("_horizontal_impulse_speed")) > 250.0, "Plataforma aplica impulso horizontal")
	player.reset_motion()
	check(is_zero_approx(float(player.get("_horizontal_impulse_speed"))), "Restart remove impulso horizontal")

	print("FASES 41-50: progressão, alcance e três mecânicas. Falhas: ", failures.size())
	quit(0 if failures.is_empty() else 1)
