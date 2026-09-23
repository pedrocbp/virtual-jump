class_name OrbitalSaw
extends Hazard

const Design := preload("res://scripts/ui/design.gd")

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
	for index in range(12):
		var angle := index * TAU / 12.0
		draw_colored_polygon(PackedVector2Array([
			Vector2.from_angle(angle - 0.13) * 19.0,
			Vector2.from_angle(angle) * 28.0,
			Vector2.from_angle(angle + 0.13) * 19.0,
		]), Design.CORAL)
	draw_circle(Vector2.ZERO, 20.0, Color("263949"))
	draw_arc(Vector2.ZERO, 18.0, 0, TAU, 32, Color("ffad98"), 2.0, true)
	draw_circle(Vector2.ZERO, 6.0, Design.CORAL)
	draw_circle(Vector2.ZERO, 2.5, Design.INK)
