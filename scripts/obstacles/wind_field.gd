extends Node2D

const Shapes := preload("res://scripts/visuals/world_shapes.gd")
const WorldStyle := preload("res://scripts/visuals/world_style.gd")

@export var zone_size := Vector2(240, 130)
@export_range(-1, 1, 2) var direction: int = 1
## Velocidade lateral adicionada dentro da corrente, em pixels por segundo.
@export_range(0, 150, 1) var strength: float = 80.0
var _time := 0.0

func _ready() -> void:
	add_to_group("wind_fields")
	add_to_group("attempt_resettable")
	z_index = -1

func push_at(world_position: Vector2) -> float:
	if Rect2(-zone_size * 0.5, zone_size).has_point(to_local(world_position)):
		return strength * signi(direction)
	return 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func reset_attempt() -> void:
	_time = 0
	queue_redraw()

func _draw() -> void:
	Shapes.wind(self, zone_size, direction, strength, _time, WorldStyle.theme_for(self))
