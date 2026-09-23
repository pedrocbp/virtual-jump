class_name VerticalCurrent
extends Node2D

@export var zone_size := Vector2(220, 160)
## -1 empurra para cima; 1 empurra para baixo.
@export_range(-1, 1, 2) var direction: int = -1
@export_range(0.0, 1800.0, 10.0) var strength: float = 1450.0

var _time := 0.0

func _ready() -> void:
	add_to_group("vertical_currents")
	add_to_group("attempt_resettable")
	z_index = -1
	queue_redraw()

func push_at(world_position: Vector2) -> float:
	if Rect2(-zone_size * 0.5, zone_size).has_point(to_local(world_position)):
		return strength * float(signi(direction))
	return 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func reset_attempt() -> void:
	_time = 0.0
	queue_redraw()

func _draw() -> void:
	var style := preload("res://scripts/visuals/world_style.gd")
	preload("res://scripts/visuals/flow_shapes.gd").wind(self, zone_size, direction, strength, _time, style.theme_for(self), true)
