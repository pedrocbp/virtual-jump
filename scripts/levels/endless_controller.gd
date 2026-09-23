class_name EndlessController
extends LevelController

const NormalPlatform := preload("res://scenes/platforms/NormalPlatform.tscn")
const MovingPlatformScene := preload("res://scenes/platforms/MovingPlatform.tscn")
const SpringPlatformScene := preload("res://scenes/platforms/SpringPlatform.tscn")
const TemporaryPlatformScene := preload("res://scenes/platforms/TemporaryPlatform.tscn")
const CrumblingPlatformScene := preload("res://scenes/platforms/CrumblingPlatform.tscn")
const SpikeScene := preload("res://scenes/obstacles/Spike.tscn")
const MovingBarScene := preload("res://scenes/obstacles/MovingBar.tscn")
const LaserScene := preload("res://scenes/obstacles/IntermittentLaser.tscn")
const WindScene := preload("res://scenes/obstacles/WindField.tscn")
const VerticalCurrentScene := preload("res://scenes/obstacles/VerticalCurrent.tscn")
const PortalScene := preload("res://scenes/obstacles/Portal.tscn")
const LayoutValidator := preload("res://scripts/levels/endless_layout_validator.gd")
const Milestone := preload("res://scripts/levels/endless_milestone.gd")

const STEP_Y := 92.0
# A mola salta o equivalente a pouco mais de tres blocos comuns.
const SPRING_STEP_Y := 300.0
const FIRST_PLATFORM_Y := 520.0
const GENERATE_AHEAD := 1500.0
const MILESTONE_BLOCKS := [25, 50, 75, 100]

var _last_y := FIRST_PLATFORM_Y
var _platform_index := 0
var _generated: Array[Node] = []
var _best_height := 0.0
var _previous_x := 120.0
var _blocks_climbed := 0
var _previous_was_spring := false
var _previous_was_spring_landing := false
var _spring_target_x := 260.0
var _previous_motion_range := 0.0
var _created_milestones: Dictionary = {}
var _platform_history: Array[Node2D] = []
var _last_portal_platform_index := -100
var _last_vertical_current_platform_index := -100

func _ready() -> void:
	var background := CanvasLayer.new()
	background.layer = -10
	add_child(background)
	var sky := Backdrop.new()
	background.add_child(sky)
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui = GameHUD.new()
	ui.controller = self
	add_child(ui)
	ui.time_label.text = "000 BLOCOS"
	_update_record_label()
	ui.progress.hide()
	player.global_position = spawn_point.global_position
	player.landed.connect(_on_landed)
	_attempt_active = true
	SaveManager.record_attempt(0)
	_generate_until(FIRST_PLATFORM_Y - GENERATE_AHEAD)
	ObjectArt.apply_to_tree(self)

func _process(_delta: float) -> void:
	if not _attempt_active:
		return
	# No modo infinito o placar mede progresso, não duração da tentativa.
	_best_height = maxf(_best_height, spawn_point.position.y - player.position.y)
	_blocks_climbed = maxi(_blocks_climbed, int(floor(_best_height / STEP_Y)))
	ui.time_label.text = "%03d BLOCOS" % _blocks_climbed
	_update_record_label()
	_generate_until(player.position.y - GENERATE_AHEAD)
	if player.global_position.y > camera.global_position.y + get_viewport_rect().size.y * 0.5 + 80.0:
		_die()

func _generate_until(target_y: float) -> void:
	while _last_y > target_y:
		var spring_landing := _previous_was_spring
		var spring_exit := _previous_was_spring_landing
		var previous_y := _last_y
		_last_y -= SPRING_STEP_Y if spring_landing else STEP_Y
		var vertical_gap := previous_y - _last_y
		_platform_index += 1
		var height_blocks := maxi(1, int(round((FIRST_PLATFORM_Y - _last_y) / STEP_Y)))
		var difficulty_tier := _difficulty_tier(height_blocks)
		var x_positions := [120.0, 240.0, 150.0, 220.0]
		var preferred_x: float = x_positions[_platform_index % x_positions.size()]
		var platform_scene: PackedScene = NormalPlatform
		var spring_interval := 11 if difficulty_tier == 2 else (9 if difficulty_tier == 3 else 8)
		var moving_interval := 6 if difficulty_tier <= 3 else 5
		if spring_landing:
			# A plataforma seguinte recebe o salto alto em um corredor central,
			# sem exigir também um grande deslocamento horizontal.
			preferred_x = _spring_target_x
		elif spring_exit:
			preferred_x = 120.0 if _previous_x > 180.0 else 240.0
		elif difficulty_tier >= 2 and _platform_index % spring_interval == 0:
			platform_scene = SpringPlatformScene
			# A mola sempre fica no lado oposto ao da plataforma anterior.
			preferred_x = 260.0 if _previous_x < 180.0 else 100.0
		elif difficulty_tier >= 2 and _platform_index % 7 == 0:
			# Mostra desgaste progressivo e cai na quarta quicada. Não recebe perigos.
			platform_scene = CrumblingPlatformScene
		elif difficulty_tier >= 2 and _platform_index % 12 == 0:
			platform_scene = TemporaryPlatformScene
		elif _platform_index % moving_interval == 0:
			platform_scene = MovingPlatformScene

		var candidate_motion_range := 24.0 if platform_scene == MovingPlatformScene else 0.0
		var wants_wind := _should_generate_wind(height_blocks, platform_scene, spring_landing, spring_exit)
		var wind_strength := _wind_strength(height_blocks) if wants_wind else 0.0
		var wants_vertical_current := _should_generate_vertical_current(
			height_blocks, platform_scene, spring_landing, spring_exit, wants_wind
		)
		# Correntes ascendentes foram removidas do infinito: elas prolongavam o
		# salto e faziam a bolinha passar por baixo/ao lado da próxima plataforma.
		var vertical_current_down := wants_vertical_current
		# A corrente descendente é curta, mas ainda reduz um pouco o alcance
		# horizontal. Esta margem faz o gerador escolher um salto mais próximo.
		var layout_penalty := wind_strength + (18.0 if vertical_current_down else 0.0)
		var x := LayoutValidator.choose_safe_x(
			preferred_x,
			_previous_x,
			vertical_gap,
			spring_landing,
			_previous_motion_range,
			candidate_motion_range,
			layout_penalty
		)
		# Se uma plataforma especial não couber de forma segura, preservamos a
		# jogabilidade usando uma plataforma normal na mesma altura.
		if is_nan(x):
			platform_scene = NormalPlatform
			candidate_motion_range = 0.0
			wants_wind = false
			wind_strength = 0.0
			wants_vertical_current = false
			vertical_current_down = false
			layout_penalty = 0.0
			x = LayoutValidator.choose_safe_x(preferred_x, _previous_x, vertical_gap, spring_landing, _previous_motion_range, 0.0, 0.0)
		if is_nan(x):
			# Reserva determinística para um caso extremo. A validação abaixo e os
			# testes longos impedem que uma sequência inválida seja silenciosa.
			x = _previous_x + 104.0 if _previous_x <= 180.0 else _previous_x - 104.0
		var layout_valid := LayoutValidator.is_platform_reachable(
			_previous_x, x, vertical_gap, spring_landing, _previous_motion_range, candidate_motion_range, layout_penalty
		)
		if not layout_valid:
			push_error("Gerador infinito não encontrou rota segura no bloco %d" % _platform_index)
		if platform_scene == SpringPlatformScene:
			_spring_target_x = 260.0 if x < 180.0 else 100.0
		var platform := platform_scene.instantiate()
		platform.position = Vector2(x, _last_y)
		platform.set_meta("endless_index", _platform_index)
		platform.set_meta("spring_landing", spring_landing)
		platform.set_meta("layout_valid", layout_valid)
		platform.set_meta("layout_x", x)
		platform.set_meta("previous_x", _previous_x)
		platform.set_meta("vertical_gap", vertical_gap)
		platform.set_meta("previous_motion_range", _previous_motion_range)
		platform.set_meta("motion_range", candidate_motion_range)
		platform.set_meta("adverse_wind_strength", layout_penalty)
		platform.set_meta("height_blocks", height_blocks)
		platform.set_meta("difficulty_tier", difficulty_tier)
		platform.set_meta("has_challenge", platform_scene != NormalPlatform or spring_landing or spring_exit)
		if platform is MovingPlatform:
			platform.travel_distance = candidate_motion_range
			platform.movement_speed = 0.75 + 0.12 * float(difficulty_tier - 1)
		add_child(platform)
		ObjectArt.apply_to_tree(platform)
		_generated.append(platform)
		_platform_history.append(platform)
		_ensure_milestones(height_blocks)

		var danger_side := 1.0 if x > _previous_x else -1.0
		if wants_wind:
			var wind := WindScene.instantiate()
			wind.position = Vector2(180.0, (previous_y + _last_y) * 0.5)
			wind.zone_size = Vector2(300.0, minf(132.0, vertical_gap + 24.0))
			wind.direction = -1 if danger_side > 0.0 else 1
			wind.strength = wind_strength
			wind.set_meta("layout_valid", true)
			wind.set_meta("height_blocks", height_blocks)
			wind.set_meta("endless_kind", "wind")
			add_child(wind)
			_generated.append(wind)
			platform.set_meta("has_challenge", true)
		if wants_vertical_current:
			var vertical_current := VerticalCurrentScene.instantiate()
			vertical_current.direction = 1
			# Atua apenas no começo do salto e termina bem abaixo da próxima
			# plataforma, evitando bloquear o pouso.
			vertical_current.position = Vector2(180.0, previous_y - 36.0)
			vertical_current.zone_size = Vector2(280.0, 70.0)
			vertical_current.strength = 180.0
			vertical_current.set_meta("layout_valid", true)
			vertical_current.set_meta("height_blocks", height_blocks)
			vertical_current.set_meta("endless_kind", "vertical_current")
			vertical_current.set_meta("previous_y", previous_y)
			vertical_current.set_meta("current_y", _last_y)
			add_child(vertical_current)
			_generated.append(vertical_current)
			platform.set_meta("has_challenge", true)
			_last_vertical_current_platform_index = _platform_index
		# Perigos só entram em plataformas normais. Assim, uma plataforma móvel,
		# temporária ou com mola nunca acumula duas dificuldades ao mesmo tempo.
		if _should_generate_hazard(height_blocks, platform_scene, spring_landing, spring_exit, wants_wind or wants_vertical_current):
			var hazard: Node
			var hazard_safe := false
			var hazard_kind := _hazard_kind(height_blocks)
			if hazard_kind == "laser":
				hazard = LaserScene.instantiate()
				hazard.beam_length = 96.0
				hazard.inactive_duration = 1.8
				hazard.warning_duration = 0.55
				hazard.active_duration = 0.9
			elif hazard_kind == "bar":
				hazard = MovingBarScene.instantiate()
			else:
				hazard = SpikeScene.instantiate()
			if hazard.get_script().resource_path.ends_with("spike.gd"):
				# O espinho ocupa apenas o lado oposto ao ponto de chegada e deixa
				# pelo menos metade da plataforma livre para pousar.
				hazard.position = Vector2(x + danger_side * 30.0, _last_y - 24.0)
				hazard_safe = LayoutValidator.is_spike_safe(x, hazard.position.x, danger_side)
			else:
				# Barras e lasers ficam na lateral do corredor, nunca no centro da
				# trajetória obrigatória entre as duas plataformas.
				var hazard_x := clampf(x + danger_side * 90.0, 26.0, 334.0)
				hazard.position = Vector2(hazard_x, _last_y + 43.0)
			if hazard is MovingBar:
				hazard.movement_axis = Vector2(1, 0)
				hazard.travel_distance = 14.0
				hazard.movement_speed = 0.8
				hazard_safe = LayoutValidator.is_side_hazard_safe(x, hazard.position.x, danger_side, hazard.travel_distance)
			elif not hazard.get_script().resource_path.ends_with("spike.gd"):
				hazard_safe = LayoutValidator.is_side_hazard_safe(x, hazard.position.x, danger_side)
			# Um perigo lateral sem corredor suficiente vira um espinho no lado
			# distante. A faixa continua desafiadora sem criar uma passagem injusta.
			if not hazard_safe and hazard_kind != "spike":
				hazard.free()
				hazard_kind = "spike"
				hazard = SpikeScene.instantiate()
				hazard.position = Vector2(x + danger_side * 30.0, _last_y - 24.0)
				hazard_safe = LayoutValidator.is_spike_safe(x, hazard.position.x, danger_side)
			if hazard_safe:
				hazard.set_meta("layout_valid", true)
				hazard.set_meta("height_blocks", height_blocks)
				hazard.set_meta("endless_kind", hazard_kind)
				add_child(hazard)
				ObjectArt.apply_to_tree(hazard)
				if hazard is Hazard:
					hazard.player_hit.connect(_on_hazard_hit)
				_generated.append(hazard)
				platform.set_meta("has_challenge", true)
			else:
				hazard.free()
		_try_generate_portal(height_blocks, platform)
		_previous_x = x
		_previous_motion_range = candidate_motion_range
		_previous_was_spring_landing = spring_landing
		_previous_was_spring = platform_scene == SpringPlatformScene

func _difficulty_tier(height_blocks: int) -> int:
	if height_blocks <= 15:
		return 1
	if height_blocks <= 30:
		return 2
	if height_blocks <= 50:
		return 3
	return 4

func _should_generate_wind(
		height_blocks: int,
		platform_scene: PackedScene,
		spring_landing: bool,
		spring_exit: bool
	) -> bool:
	if height_blocks < 31 or platform_scene != NormalPlatform or spring_landing or spring_exit:
		return false
	if not is_zero_approx(_previous_motion_range):
		return false
	var interval := 9 if height_blocks <= 50 else 7
	return _platform_index % interval == 3

func _wind_strength(height_blocks: int) -> float:
	return 42.0 if height_blocks <= 50 else 58.0

func _should_generate_vertical_current(
		height_blocks: int,
		platform_scene: PackedScene,
		spring_landing: bool,
		spring_exit: bool,
		has_horizontal_wind: bool
	) -> bool:
	if height_blocks < 45 or platform_scene != NormalPlatform or spring_landing or spring_exit or has_horizontal_wind:
		return false
	if not is_zero_approx(_previous_motion_range):
		return false
	if _platform_history.is_empty() or bool(_platform_history.back().get_meta("has_challenge", true)):
		return false
	return _platform_index - _last_vertical_current_platform_index >= 13

func _try_generate_portal(height_blocks: int, exit_platform: Node2D) -> void:
	if height_blocks < 55 or _platform_index - _last_portal_platform_index < 15:
		return
	if bool(exit_platform.get_meta("has_challenge", true)) or bool(exit_platform.get_meta("portal_reserved", false)):
		return
	if _platform_history.size() < 6:
		return
	var entry_platform: Node2D
	for offset in [3, 4, 5]:
		var candidate := _platform_history[_platform_history.size() - 1 - offset]
		if not is_instance_valid(candidate):
			continue
		if bool(candidate.get_meta("has_challenge", true)) or bool(candidate.get_meta("portal_reserved", false)):
			continue
		entry_platform = candidate
		break
	if entry_platform == null:
		return
	var entry := PortalScene.instantiate()
	var exit_portal := PortalScene.instantiate()
	entry.name = "EndlessPortalEntry%d" % _platform_index
	exit_portal.name = "EndlessPortalExit%d" % _platform_index
	entry.position = entry_platform.position + Vector2(0.0, -50.0)
	exit_portal.position = exit_platform.position + Vector2(0.0, -40.0)
	entry.target_path = NodePath("../" + exit_portal.name)
	entry.intermittent = true
	entry.visible_duration = 2.6
	entry.hidden_duration = 1.8
	entry.warning_duration = 0.45
	entry.cycle_offset = fmod(float(_platform_index) * 0.63, entry.visible_duration + entry.hidden_duration)
	exit_portal.active = false
	exit_portal.portal_color = Color("69c9ff")
	for portal in [entry, exit_portal]:
		portal.set_meta("layout_valid", true)
		portal.set_meta("height_blocks", height_blocks)
		portal.set_meta("endless_kind", "portal_entry" if portal == entry else "portal_exit")
	add_child(exit_portal)
	add_child(entry)
	_generated.append(exit_portal)
	_generated.append(entry)
	entry_platform.set_meta("portal_reserved", true)
	exit_platform.set_meta("portal_reserved", true)
	entry_platform.set_meta("has_challenge", true)
	exit_platform.set_meta("has_challenge", true)
	_last_portal_platform_index = _platform_index

func _should_generate_hazard(
		height_blocks: int,
		platform_scene: PackedScene,
		spring_landing: bool,
		spring_exit: bool,
		has_wind: bool
	) -> bool:
	if height_blocks < 16 or platform_scene != NormalPlatform or spring_landing or spring_exit or has_wind:
		return false
	var interval := 6 if height_blocks <= 50 else 4
	var cycle_position := 3 if height_blocks <= 50 else 2
	return _platform_index % interval == cycle_position

func _hazard_kind(height_blocks: int) -> String:
	if height_blocks <= 30:
		return "spike"
	var cycle := int(floor(float(height_blocks) / (6.0 if height_blocks <= 50 else 4.0)))
	if height_blocks <= 50:
		return "laser" if cycle % 2 == 0 else "spike"
	match cycle % 3:
		0:
			return "laser"
		1:
			return "bar"
		_:
			return "spike"

func _ensure_milestones(height_blocks: int) -> void:
	for milestone_blocks in MILESTONE_BLOCKS:
		if height_blocks < milestone_blocks or _created_milestones.has(milestone_blocks):
			continue
		var marker := Milestone.new()
		marker.block_value = milestone_blocks
		marker.position = Vector2(0.0, FIRST_PLATFORM_Y - float(milestone_blocks) * STEP_Y)
		marker.set_meta("endless_kind", "milestone")
		marker.set_meta("height_blocks", milestone_blocks)
		add_child(marker)
		_generated.append(marker)
		_created_milestones[milestone_blocks] = marker

func _update_record_label() -> void:
	if ui != null and ui.record_label != null:
		ui.record_label.text = "RECORDE %03d BLOCOS" % maxi(SaveManager.get_endless_best_blocks(), _blocks_climbed)

func _save_endless_record() -> void:
	SaveManager.record_endless_best(_blocks_climbed)
	_update_record_label()

func _die() -> void:
	if _dying or not _attempt_active:
		return
	_dying = true
	_attempt_active = false
	SaveManager.record_death()
	var previous_best := SaveManager.get_endless_best_blocks()
	var is_record := _blocks_climbed > previous_best
	_save_endless_record()
	player.play_death()
	player.set_physics_process(false)
	Feedback.play_sound("death")
	Feedback.vibrate(55)
	camera.shake(5.5, 0.2)
	ui.flash_death()
	await get_tree().create_timer(0.28, false).timeout
	_dying = false
	ui.show_endless_result(_blocks_climbed, SaveManager.get_endless_best_blocks(), is_record)

func go_to_levels() -> void:
	_save_endless_record()
	super.go_to_levels()

func _exit_tree() -> void:
	_save_endless_record()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_save_endless_record()

func restart_attempt() -> void:
	if _dying or Feedback.transitioning:
		return
	_save_endless_record()
	get_tree().paused = false
	ui.pause_menu.hide()
	ui.result.hide()
	_completed = false
	_attempt_active = false
	SaveManager.record_attempt(0)
	_elapsed_seconds = 0.0
	_best_height = 0.0
	_blocks_climbed = 0
	_last_y = FIRST_PLATFORM_Y
	_platform_index = 0
	_previous_x = 120.0
	_previous_was_spring = false
	_previous_was_spring_landing = false
	_spring_target_x = 260.0
	_previous_motion_range = 0.0
	_created_milestones.clear()
	_platform_history.clear()
	_last_portal_platform_index = -100
	_last_vertical_current_platform_index = -100
	for node in _generated:
		if is_instance_valid(node):
			node.queue_free()
	_generated.clear()
	player.set_physics_process(false)
	player.reset_motion()
	player.global_position = spawn_point.global_position
	camera.reset_camera()
	ui.time_label.text = "000 BLOCOS"
	_generate_until(FIRST_PLATFORM_Y - GENERATE_AHEAD)
	player.set_physics_process(true)
	_attempt_active = true
