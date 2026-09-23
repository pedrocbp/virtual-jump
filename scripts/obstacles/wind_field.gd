extends Node2D

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

func _draw() -> void:
	var bounds := Rect2(-zone_size * 0.5, zone_size)
	draw_rect(bounds, Color(0.3, 0.75, 0.95, 0.055))
	draw_rect(bounds, Color(0.4, 0.82, 1.0, 0.23), false, 1)
	for index in range(12):
		var travel := fposmod(index * 43.0 + _time * 65 * direction, zone_size.x - 30)
		var point := bounds.position + Vector2(15 + travel, 15 + (index % 4) * (zone_size.y - 30) / 3.0)
		var end := point + Vector2(14 * direction, 0)
		draw_line(point, end, Color(0.45, 0.83, 1.0, 0.4), 1.5, true)
		draw_polyline(PackedVector2Array([end + Vector2(-4 * direction, -3), end, end + Vector2(-4 * direction, 3)]), Color(0.45, 0.83, 1.0, 0.4), 1, true)
	var fan := Vector2(-direction * (zone_size.x * 0.5 - 14), 0)
	draw_circle(fan, 12, Color("1c3548"))
	draw_arc(fan, 12, 0, TAU, 32, Color("80caff"), 1.5, true)
	for index in range(3):
		var vector := Vector2.from_angle(_time * 4 + index * TAU / 3)
		draw_line(fan + vector * 3, fan + vector * 9, Color("80caff"), 3, true)
