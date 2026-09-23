class_name GamePortal
extends Area2D

const Design := preload("res://scripts/ui/design.gd")

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

func _ready() -> void:
	add_to_group("attempt_resettable")
	_time = cycle_offset
	_update_availability()
	if active:
		body_entered.connect(_on_body_entered)
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta
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
	var feedback := get_node_or_null("/root/Feedback")
	if feedback != null:
		feedback.play_sound("win")
		feedback.vibrate(14)

func reset_attempt() -> void:
	_time = cycle_offset
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

func _draw() -> void:
	if intermittent and active and not _available:
		var cycle := maxf(0.1, visible_duration + hidden_duration)
		var cycle_time := fposmod(_time, cycle)
		var hidden_progress := cycle_time - visible_duration
		var time_until_open := hidden_duration - hidden_progress
		if time_until_open > warning_duration:
			return
		# Um anel discreto cresce antes da reabertura para o jogador antecipar
		# a janela, sem tornar o portal utilizável durante o aviso.
		var warning_progress := 1.0 - clampf(time_until_open / warning_duration, 0.0, 1.0)
		var warning_color := Color(portal_color, 0.18 + warning_progress * 0.42)
		draw_arc(Vector2.ZERO, lerpf(10.0, 20.0, warning_progress), -PI * 0.5, PI * 1.5, 28, warning_color, 2.0, true)
		for index in range(3):
			var point := Vector2.from_angle(index * TAU / 3.0 - PI * 0.5) * 15.0
			draw_circle(point, 1.5 + warning_progress, warning_color)
		return
	var pulse := 1.0 + sin(_time * 3.2) * 0.06
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * pulse)
	draw_circle(Vector2.ZERO, 25.0, Color(portal_color, 0.10))
	draw_arc(Vector2.ZERO, 20.0, 0, TAU, 40, Color(portal_color, 0.9), 3.0, true)
	draw_arc(Vector2.ZERO, 13.0, -_time * 1.8, TAU - _time * 1.8, 32, Color("dcd4ff"), 2.0, true)
	draw_circle(Vector2.ZERO, 6.0, Color(Design.INK, 0.88))
	for index in range(3):
		var point := Vector2.from_angle(_time * 1.5 + index * TAU / 3.0) * 16.0
		draw_circle(point, 1.8, Color("f0edff"))
