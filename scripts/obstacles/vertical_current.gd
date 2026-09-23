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
	var bounds := Rect2(-zone_size * 0.5, zone_size)
	draw_rect(bounds, Color(0.55, 0.45, 1.0, 0.055))
	draw_rect(bounds, Color(0.65, 0.55, 1.0, 0.28), false, 1.0)
	var arrow_direction := float(signi(direction))
	for index in range(12):
		var column := index % 4
		var row := floori(float(index) / 4.0)
		var travel := fposmod(float(row) * 41.0 + _time * 70.0 * arrow_direction, zone_size.y - 28.0)
		var point := bounds.position + Vector2(24.0 + column * (zone_size.x - 48.0) / 3.0, 14.0 + travel)
		var end := point + Vector2(0, 14.0 * arrow_direction)
		draw_line(point, end, Color(0.72, 0.65, 1.0, 0.48), 1.5, true)
		draw_polyline(PackedVector2Array([
			end + Vector2(-3, -4 * arrow_direction), end, end + Vector2(3, -4 * arrow_direction)
		]), Color(0.72, 0.65, 1.0, 0.48), 1.2, true)
