class_name MovingBar
extends Hazard

@export var movement_axis: Vector2 = Vector2.UP
@export var travel_distance: float = 100.0
@export var movement_speed: float = 1.5

var _origin: Vector2
var _movement_time := 0.0


func _ready() -> void:
	super._ready()
	_origin = position


func _physics_process(delta: float) -> void:
	_movement_time += delta * movement_speed
	position = _origin + movement_axis.normalized() * sin(_movement_time) * travel_distance


func reset_attempt() -> void:
	_movement_time = 0.0
	position = _origin
