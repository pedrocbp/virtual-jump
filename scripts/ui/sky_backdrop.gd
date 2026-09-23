extends Control

const Design := preload("res://scripts/ui/design.gd")

var hero := false
var hero_center_y := 206.0
var _time := 0.0

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	set_process(hero)

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Design.INK)
	for row in range(20):
		var shade := Color("14283d").lerp(Design.INK, float(row) / 20.0)
		draw_rect(Rect2(0, row * size.y / 20.0, size.x, size.y / 20.0 + 1), shade)
	for i in range(34):
		var point := Vector2(fmod(i * 97.0 + 23.0, maxf(1, size.x)), fmod(i * 131.0 + 51.0, maxf(1, size.y)))
		draw_circle(point, 1.0 if i % 3 else 1.8, Color(0.6, 0.8, 0.95, 0.16))
	if not hero:
		return
	var center := Vector2(size.x * 0.5, hero_center_y)
	draw_arc(center, 85, -2.8, -0.35, 64, Color("30465d"), 1.0, true)
	draw_arc(center, 65, 0.2, 2.7, 64, Color("30465d"), 1.0, true)
	for i in range(3):
		var origin := center + Vector2(-84 + i * 54, 55 - i * 32)
		Design.box(Color("244458"), Color("80efc0"), 5).draw(get_canvas_item(), Rect2(origin, Vector2(60, 12)))
	var bob := sin(_time * 1.7) * 5.0
	draw_circle(center + Vector2(8, -17 + bob), 30, Color(0.5, 0.94, 0.75, 0.08))
	draw_circle(center + Vector2(8, -17 + bob), 20, Design.MINT)
	draw_circle(center + Vector2(1, -24 + bob), 7, Color("dbfff1"))
