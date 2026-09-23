extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error(message)
	quit(1)

func _run() -> void:
	if change_scene_to_file("res://scenes/endless/Endless.tscn") != OK:
		_fail("Não foi possível abrir o modo infinito")
		return
	for _frame in range(5):
		await process_frame

	var endless := current_scene
	endless._generate_until(-30000.0)
	await process_frame
	var validator = load("res://scripts/levels/endless_layout_validator.gd")
	var platforms: Array[Node] = []
	var hazard_count := 0
	var wind_count := 0
	var vertical_current_count := 0
	var upward_current_count := 0
	var downward_current_count := 0
	var portal_entry_count := 0
	var portal_exit_count := 0
	var milestone_count := 0
	var hazard_kinds := {"spike": 0, "laser": 0, "bar": 0}
	var hazards_by_tier := {2: 0, 3: 0, 4: 0}
	var winds_by_tier := {3: 0, 4: 0}
	var special_counts := {
		"spring": 0,
		"moving": 0,
		"crumbling": 0,
		"temporary": 0,
	}
	for generated: Node in endless._generated:
		if generated.has_meta("endless_index"):
			platforms.append(generated)
			var height_blocks := int(generated.get_meta("height_blocks"))
			var expected_tier := 1 if height_blocks <= 15 else (2 if height_blocks <= 30 else (3 if height_blocks <= 50 else 4))
			if int(generated.get_meta("difficulty_tier")) != expected_tier:
				_fail("Faixa de dificuldade incorreta no bloco %d" % height_blocks)
				return
			var script_resource: Script = generated.get_script()
			var script_path := script_resource.resource_path if script_resource != null else ""
			if height_blocks <= 15 and not script_path.is_empty() and not script_path.ends_with("moving_platform.gd"):
				_fail("Mecânica avançada apareceu cedo demais no bloco %d" % height_blocks)
				return
			if script_path.ends_with("spring_platform.gd"):
				special_counts["spring"] += 1
			elif script_path.ends_with("moving_platform.gd"):
				special_counts["moving"] += 1
			elif script_path.ends_with("crumbling_platform.gd"):
				special_counts["crumbling"] += 1
			elif script_path.ends_with("temporary_platform.gd"):
				special_counts["temporary"] += 1
		elif generated is Hazard:
			hazard_count += 1
			var hazard_height := int(generated.get_meta("height_blocks"))
			var hazard_kind := String(generated.get_meta("endless_kind"))
			if hazard_height <= 15:
				_fail("Perigo apareceu na faixa inicial")
				return
			if hazard_height <= 30 and hazard_kind != "spike":
				_fail("Laser ou barra apareceu antes do bloco 31")
				return
			if hazard_kinds.has(hazard_kind):
				hazard_kinds[hazard_kind] += 1
			var hazard_tier := 2 if hazard_height <= 30 else (3 if hazard_height <= 50 else 4)
			hazards_by_tier[hazard_tier] += 1
			if not bool(generated.get_meta("layout_valid", false)):
				_fail("Perigo inválido foi adicionado ao modo infinito")
				return
		elif String(generated.get_meta("endless_kind", "")) == "wind":
			wind_count += 1
			var wind_height := int(generated.get_meta("height_blocks"))
			if wind_height < 31:
				_fail("Vento apareceu antes do bloco 31")
				return
			winds_by_tier[3 if wind_height <= 50 else 4] += 1
		elif String(generated.get_meta("endless_kind", "")) == "vertical_current":
			vertical_current_count += 1
			var current_height := int(generated.get_meta("height_blocks"))
			if current_height < 45 or not bool(generated.get_meta("layout_valid", false)):
				_fail("Corrente vertical apareceu cedo ou sem validação")
				return
			if int(generated.direction) < 0:
				upward_current_count += 1
			else:
				downward_current_count += 1
				var current_top: float = generated.position.y - generated.zone_size.y * 0.5
				var landing_y := float(generated.get_meta("current_y"))
				if generated.strength > 180.0 or generated.zone_size.y > 70.0 or current_top < landing_y + 15.0:
					_fail("Corrente descendente pode bloquear o próximo pouso")
					return
		elif String(generated.get_meta("endless_kind", "")) == "portal_entry":
			portal_entry_count += 1
			if not bool(generated.intermittent) or float(generated.visible_duration) < 2.0 or float(generated.hidden_duration) < 1.0:
				_fail("Portal de entrada sem ciclo intermitente jogável")
				return
			var target := generated.get_node_or_null(generated.target_path) as Node2D
			if target == null or target.position.y > generated.position.y - 180.0:
				_fail("Portal sem saída segura acima")
				return
		elif String(generated.get_meta("endless_kind", "")) == "portal_exit":
			portal_exit_count += 1
		elif String(generated.get_meta("endless_kind", "")) == "milestone":
			milestone_count += 1

	platforms.sort_custom(func(a: Node, b: Node) -> bool:
		return int(a.get_meta("endless_index")) < int(b.get_meta("endless_index"))
	)
	if platforms.size() < 200:
		_fail("Teste longo gerou poucas plataformas: %d" % platforms.size())
		return
	if hazard_count < 10:
		_fail("Teste longo não exercitou perigos suficientes: %d" % hazard_count)
		return
	if wind_count < 5:
		_fail("Teste longo não exercitou correntes de ar suficientes: %d" % wind_count)
		return
	if vertical_current_count < 5 or upward_current_count != 0 or downward_current_count != vertical_current_count:
		_fail("Correntes verticais incorretas: %d (%d cima, %d baixo)" % [vertical_current_count, upward_current_count, downward_current_count])
		return
	if portal_entry_count < 3 or portal_entry_count != portal_exit_count:
		_fail("Pares de portais insuficientes ou incompletos: %d entradas, %d saídas" % [portal_entry_count, portal_exit_count])
		return
	if milestone_count != 4:
		_fail("Marcos visuais incorretos: %d" % milestone_count)
		return
	for hazard_kind: String in hazard_kinds:
		if int(hazard_kinds[hazard_kind]) < 1:
			_fail("Progressão não gerou perigo do tipo %s" % hazard_kind)
			return
	for tier: int in hazards_by_tier:
		if int(hazards_by_tier[tier]) < 1:
			_fail("Faixa %d não gerou nenhum perigo" % tier)
			return
	for tier: int in winds_by_tier:
		if int(winds_by_tier[tier]) < 1:
			_fail("Faixa %d não gerou nenhuma corrente de ar" % tier)
			return
	for special: String in special_counts:
		if int(special_counts[special]) < 5:
			_fail("Teste longo perdeu plataformas especiais do tipo %s" % special)
			return

	for platform: Node2D in platforms:
		var valid: bool = validator.is_platform_reachable(
			float(platform.get_meta("previous_x")),
			float(platform.get_meta("layout_x")),
			float(platform.get_meta("vertical_gap")),
			bool(platform.get_meta("spring_landing")),
			float(platform.get_meta("previous_motion_range")),
			float(platform.get_meta("motion_range")),
			float(platform.get_meta("adverse_wind_strength"))
		)
		if not valid or not bool(platform.get_meta("layout_valid")):
			_fail("Plataforma inalcançável no bloco %d" % int(platform.get_meta("endless_index")))
			return
		if bool(platform.get_meta("spring_landing")):
			var required_gap := float(platform.get_meta("vertical_gap"))
			var spring_force: float = float(validator.SPRING_JUMP_FORCE)
			var spring_gravity: float = float(validator.GRAVITY)
			var spring_apex: float = spring_force * spring_force / (2.0 * spring_gravity)
			if required_gap + 48.0 > spring_apex:
				_fail("Mola sem margem vertical suficiente no bloco %d" % int(platform.get_meta("endless_index")))
				return

	print("ENDLESS VALIDATION: %d plataformas, %d perigos, %d ventos, %d correntes verticais, %d portais e 4 marcos seguros" % [platforms.size(), hazard_count, wind_count, vertical_current_count, portal_entry_count])
	quit(0)
