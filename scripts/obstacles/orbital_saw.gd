class_name OrbitalSaw
extends Hazard

const Shapes := preload("res://scripts/visuals/world_shapes.gd")
const WorldStyle := preload("res://scripts/visuals/world_style.gd")

@export var orbit_radius: float = 34.0
@export var orbit_speed: float = 1.35
@export var start_angle: float = 0.0
@export var clockwise: bool = true

var _pivot := Vector2.ZERO
var _angle := 0.0

func _ready() -> void:
	super._ready()
	_pivot = position
	_angle = start_angle
	_apply_orbit()

func _physics_process(delta: float) -> void:
	var direction := 1.0 if clockwise else -1.0
	_angle += delta * orbit_speed * direction
	_apply_orbit()
	rotation += delta * 3.8 * direction

func _apply_orbit() -> void:
	position = _pivot + Vector2.from_angle(_angle) * orbit_radius

func reset_attempt() -> void:
	_angle = start_angle
	rotation = 0.0
	_apply_orbit()

func _draw() -> void:
	var shape := $CollisionShape2D.shape as CircleShape2D
	Shapes.saw(self, shape.radius, WorldStyle.theme_for(self))
