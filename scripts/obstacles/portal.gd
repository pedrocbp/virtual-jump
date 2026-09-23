class_name GamePortal
extends Area2D

const Shapes := preload("res://scripts/visuals/world_shapes.gd")
const WorldStyle := preload("res://scripts/visuals/world_style.gd")

@export var target_path: NodePath
@export var exit_offset := Vector2.ZERO
@export var active := true
@export var portal_color := Color("9c7cff")
@export var intermittent := false
@export_range(0.5, 10.0, 0.1) var visible_duration := 2.6
@export_range(0.5, 10.0, 0.1) var hidden_duration := 1.8
@export_range(0.1, 1.0, 0.05) var warning_duration := 0.45
@export var cycle_offset := 0.0

var _time := 0.0
var _available := true
var _transfer_pulse := 0.0

func _ready() -> void:
	add_to_group("attempt_resettable")
	_time = cycle_offset
	_update_availability()
	if active:
		body_entered.connect(_on_body_entered)
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	_transfer_pulse = maxf(0, _transfer_pulse - delta)
	_update_availability()
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if not active or not _available or not body is Player:
		return
	var current_frame := Engine.get_physics_frames()
	if current_frame < int(body.get_meta("portal_lock_until", -1)):
		return
	var target := get_node_or_null(target_path) as Node2D
	if target == null:
		return
	body.set_meta("portal_lock_until", current_frame + 12)
	body.global_position = target.global_position + exit_offset
	body.velocity.y = minf(body.velocity.y, -240.0)
	body.reset_physics_interpolation()
	play_transfer_visual()
	if target.has_method("play_transfer_visual"):
		target.play_transfer_visual()
	var feedback := get_node_or_null("/root/Feedback")
	if feedback != null:
		feedback.play_sound("win")
		feedback.vibrate(14)

func reset_attempt() -> void:
	_time = cycle_offset
	_transfer_pulse = 0.0
	_update_availability()
	queue_redraw()

func is_available() -> bool:
	return active and _available

func _update_availability() -> void:
	if not active:
		_available = false
	elif not intermittent:
		_available = true
	else:
		var cycle := maxf(0.1, visible_duration + hidden_duration)
		_available = fposmod(_time, cycle) < visible_duration
	monitoring = active and _available

func play_transfer_visual() -> void:
	_transfer_pulse = 0.22
	queue_redraw()

func get_visual_state() -> Dictionary:
	var warning := -1.0
	var remaining := -1.0
	var hidden := false
	if intermittent and active and not _available:
		var cycle := maxf(0.1, visible_duration + hidden_duration)
		var cycle_time := fposmod(_time, cycle)
		var hidden_progress := cycle_time - visible_duration
		var time_until_open := hidden_duration - hidden_progress
		if time_until_open > warning_duration:
			hidden = true
		warning = 1.0 - clampf(time_until_open / warning_duration, 0.0, 1.0)
	elif intermittent and active:
		remaining = 1.0 - fposmod(_time, visible_duration + hidden_duration) / visible_duration
	return {"hidden": hidden, "warning": warning, "remaining": remaining, "entry": active, "available": is_available(), "pulse": _transfer_pulse}

func _draw() -> void:
	var state := get_visual_state()
	if state.hidden:
		return
	var shape := $CollisionShape2D.shape as CircleShape2D
	Shapes.portal(self, shape.radius, active, _time, state.warning, state.remaining, WorldStyle.theme_for(self), portal_color)
	if _transfer_pulse > 0 and state.warning < 0:
		var progress := 1.0 - _transfer_pulse / 0.22
		var tint := WorldStyle.color("portal" if active else "flow", WorldStyle.theme_for(self))
		tint.a = 1.0 - progress
		draw_arc(Vector2.ZERO, shape.radius + 2 + progress * 7, 0, TAU, 48, tint, 1.5, true)
