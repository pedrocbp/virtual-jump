class_name MovingSaw
extends Hazard

@export var movement_axis: Vector2 = Vector2.RIGHT
@export var travel_distance: float = 90.0
@export var movement_speed: float = 1.4
@export var rotation_speed: float = 5.0

var _origin: Vector2
var _initial_rotation: float
var _movement_time := 0.0


func _ready() -> void:
	super._ready()
	_origin = position
	_initial_rotation = rotation


func _physics_process(delta: float) -> void:
	_movement_time += delta * movement_speed
	position = _origin + movement_axis.normalized() * sin(_movement_time) * travel_distance
	rotation += delta * rotation_speed


func reset_attempt() -> void:
	_movement_time = 0.0
	position = _origin
	rotation = _initial_rotation
