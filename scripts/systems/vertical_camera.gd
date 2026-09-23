class_name VerticalCamera
extends Camera2D

## O jogador permanece nesta altura da tela antes de a câmera começar a subir.
@export var follow_start_y: float = 240.0
@export var follow_offset_y: float = 80.0
@export var camera_start_position: Vector2 = Vector2(180.0, 320.0)

var _target: Node2D
var _highest_camera_y: float
var _shake_remaining := 0.0
var _shake_duration := 0.0
var _shake_intensity := 0.0
var _shake_phase := 0.0


func _ready() -> void:
	_target = get_node_or_null(NodePath("../Player")) as Node2D
	enabled = true
	make_current()
	position = camera_start_position
	_highest_camera_y = position.y
	position_smoothing_enabled = true
	position_smoothing_speed = 6.0


func _process(delta: float) -> void:
	if _target == null:
		return

	var desired_y := _target.global_position.y + follow_offset_y
	if _target.global_position.y < follow_start_y:
		_highest_camera_y = min(_highest_camera_y, desired_y)

	# A câmera só sobe; ela nunca retorna durante a tentativa.
	position = Vector2(camera_start_position.x, _highest_camera_y)
	_update_shake(delta)


func shake(intensity: float = 4.0, duration: float = 0.16) -> void:
	_shake_intensity = maxf(_shake_intensity, intensity)
	_shake_duration = maxf(_shake_duration, duration)
	_shake_remaining = maxf(_shake_remaining, duration)


func _update_shake(delta: float) -> void:
	if _shake_remaining <= 0.0:
		offset = Vector2.ZERO
		_shake_intensity = 0.0
		_shake_duration = 0.0
		return
	_shake_remaining = maxf(0.0, _shake_remaining - delta)
	_shake_phase += delta * 58.0
	var fade := _shake_remaining / maxf(_shake_duration, 0.001)
	offset = Vector2(sin(_shake_phase * 1.7), cos(_shake_phase * 2.3)) * _shake_intensity * fade


func reset_camera() -> void:
	_highest_camera_y = camera_start_position.y
	_shake_remaining = 0.0
	_shake_duration = 0.0
	_shake_intensity = 0.0
	offset = Vector2.ZERO
	position_smoothing_enabled = false
	position = camera_start_position
	position_smoothing_enabled = true
