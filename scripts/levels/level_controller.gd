class_name LevelController
extends Node2D

const Catalog := preload("res://scripts/systems/level_catalog.gd")

const Design := preload("res://scripts/ui/design.gd")

@export var level_config: LevelConfig
const FALL_SCREEN_MARGIN := 64.0
const Burst := preload("res://scripts/effects/burst.gd")
const ObjectArt := preload("res://scripts/effects/object_skin.gd")
const Backdrop := preload("res://scripts/ui/sky_backdrop.gd")

var _completed := false
var _attempt_active := false
var _dying := false
var _elapsed_seconds := 0.0
var _highest_progress := 0.0
var ui: GameHUD

@onready var player: Player = $Player
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var camera: VerticalCamera = $Camera2D

func _ready() -> void:
	if level_config == null:
		level_config = load("res://resources/levels/level01_config.tres") as LevelConfig
	var background := CanvasLayer.new()
	background.layer = -10
	add_child(background)
	var sky := Backdrop.new()
	background.add_child(sky)
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui = GameHUD.new()
	ui.controller = self
	add_child(ui)
	player.global_position = spawn_point.global_position
	player.landed.connect(_on_landed)
	$Goal.player_reached.connect(_on_goal_reached)
	Feedback.pause_requested.connect(toggle_pause)
	call_deferred("_finish_setup")
	_attempt_active = true
	SaveManager.record_attempt(level_config.level_number)

func _finish_setup() -> void:
	ObjectArt.apply_to_tree(get_parent())
	if level_config.has_hazards:
		for hazard_node in get_tree().get_nodes_in_group("hazards"):
			if hazard_node is Hazard and not hazard_node.player_hit.is_connected(_on_hazard_hit):
				hazard_node.player_hit.connect(_on_hazard_hit)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and not _dying:
		restart_attempt()

func _process(delta: float) -> void:
	if not _attempt_active:
		return
	if player.get_global_transform_with_canvas().origin.y > get_viewport_rect().size.y + FALL_SCREEN_MARGIN:
		_die()
		return
	_elapsed_seconds += delta
	ui.time_label.text = Design.time(_elapsed_seconds)
	var total_height: float = spawn_point.position.y - $Goal.position.y
	_highest_progress = maxf(_highest_progress, clampf((spawn_point.position.y - player.position.y) / maxf(1.0, total_height), 0, 1))
	ui.progress.value = _highest_progress * 100.0

func _on_landed(point: Vector2, impact_speed: float) -> void:
	if not _attempt_active:
		return
	var impact := clampf(impact_speed / player.jump_force, 0.72, 1.2)
	Feedback.play_sound("land")
	Feedback.vibrate(8)
	camera.shake(0.65 + impact * 0.45, 0.075)
	_burst(point, Design.MINT, 0.62 + impact * 0.18, "landing")

func _burst(point: Vector2, tint: Color, strength: float, kind: String = "radial") -> void:
	var burst := Burst.new()
	burst.position = to_local(point)
	burst.tint = tint
	burst.strength = strength
	burst.kind = kind
	burst.duration = 0.26 if kind == "death" else (0.22 if kind == "landing" else 0.4)
	add_child(burst)

func _on_goal_reached(_player: Player) -> void:
	if _completed or not _attempt_active:
		return
	_completed = true
	_attempt_active = false
	var previous_best := SaveManager.get_best_time(level_config.level_number)
	var medal_rank := level_config.get_medal_rank(_elapsed_seconds)
	SaveManager.record_completion(level_config.level_number, _elapsed_seconds, medal_rank)
	player.velocity = Vector2.ZERO
	player.release_controls()
	player.set_physics_process(false)
	ui.progress.value = 100
	Feedback.play_sound("win")
	Feedback.vibrate(35)
	_burst(player.global_position, Design.GOLD, 1.8, "win")
	ui.show_result(_elapsed_seconds, SaveManager.get_best_time(level_config.level_number), medal_rank, previous_best < 0 or _elapsed_seconds < previous_best)

func _on_hazard_hit(_player: Player) -> void:
	if _attempt_active:
		_die()

func _die() -> void:
	if _dying or not _attempt_active:
		return
	_dying = true
	_attempt_active = false
	SaveManager.record_death()
	player.play_death()
	player.set_physics_process(false)
	Feedback.play_sound("death")
	Feedback.vibrate(55)
	camera.shake(5.5, 0.2)
	_burst(player.global_position, player.get_trail_color(), 1.15, "death")
	ui.flash_death()
	await get_tree().create_timer(0.28, false).timeout
	_dying = false
	restart_attempt()

func restart_attempt() -> void:
	if _dying or Feedback.transitioning:
		return
	get_tree().paused = false
	ui.pause_menu.hide()
	ui.result.hide()
	_completed = false
	_attempt_active = false
	SaveManager.record_attempt(level_config.level_number)
	_elapsed_seconds = 0.0
	_highest_progress = 0
	player.set_physics_process(false)
	player.reset_motion()
	player.global_position = spawn_point.global_position
	for resettable in get_tree().get_nodes_in_group("attempt_resettable"):
		if resettable.has_method("reset_attempt"):
			resettable.call("reset_attempt")
	camera.reset_camera()
	ui.time_label.text = Design.time(0)
	ui.progress.value = 0
	player.set_physics_process(true)
	_attempt_active = true

func toggle_pause() -> void:
	if _completed or Feedback.transitioning:
		return
	var should_pause := not get_tree().paused
	get_tree().paused = should_pause
	ui.pause_menu.visible = should_pause
	if should_pause:
		player.release_controls()
	else:
		player.controls_enabled = not _dying

func go_to_levels() -> void:
	player.release_controls()
	Feedback.change_scene("res://scenes/ui/LevelSelect.tscn")

func next_level() -> void:
	if level_config.level_number >= Catalog.TOTAL_LEVELS:
		go_to_levels()
	else:
		Feedback.change_scene("res://scenes/levels/Level%02d.tscn" % (level_config.level_number + 1))
