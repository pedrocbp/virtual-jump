class_name TemporaryPlatform
extends StaticBody2D

@export var active_duration: float = 2.5
@export var inactive_duration: float = 1.5

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Polygon2D = $Visual

var _is_active := true
var _state_time := 0.0


func _ready() -> void:
	add_to_group("attempt_resettable")


func _physics_process(delta: float) -> void:
	_state_time += delta
	if _is_active and _state_time >= active_duration:
		_set_active(false)
	elif not _is_active and _state_time >= inactive_duration:
		_set_active(true)


func _set_active(active: bool) -> void:
	_is_active = active
	_state_time = 0.0
	collision_shape.set_deferred("disabled", not active)
	visual.visible = active


func reset_attempt() -> void:
	_set_active(true)
