class_name MovingPlatform
extends AnimatableBody2D

@export var movement_axis: Vector2 = Vector2.RIGHT
@export var travel_distance: float = 70.0
@export var movement_speed: float = 1.2

var _origin: Vector2
var _movement_time := 0.0


func _ready() -> void:
	add_to_group("attempt_resettable")
	_origin = position


func _physics_process(delta: float) -> void:
	_movement_time += delta * movement_speed
	var direction := movement_axis.normalized()
	position = _origin + direction * sin(_movement_time) * travel_distance


func reset_attempt() -> void:
	_movement_time = 0.0
	# Teleporte imediato no restart, sem o deslocamento pendente do corpo animável.
	sync_to_physics = false
	position = _origin
	reset_physics_interpolation()
	sync_to_physics = true
