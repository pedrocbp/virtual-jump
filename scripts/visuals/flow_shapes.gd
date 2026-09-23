extends RefCounted
## Shared, purely cosmetic flow renderer. All marks stay inside the force area.
const Style := preload("res://scripts/visuals/world_style.gd")

static func wind(canvas: Node2D, size: Vector2, direction: int, strength: float, time: float, theme: int, vertical := false) -> void:
	if minf(size.x, size.y) < 8:
		return
	var tint := Style.color("flow", theme)
	var axis := Vector2.DOWN if vertical else Vector2.RIGHT
	var cross_axis := Vector2.RIGHT if vertical else Vector2.DOWN
	var length := size.y if vertical else size.x
	var breadth := size.x if vertical else size.y
	var signed_direction := float(signi(direction))
	var power := clampf(strength / (1800.0 if vertical else 150.0), 0.0, 1.0)
	var speed := lerpf(25, 75, power)
	var corner_length := minf(7, minf(size.x, size.y) * 0.2)
	for x in [-1, 1]:
		for y in [-1, 1]:
			var corner := Vector2(x * (size.x * 0.5 - 1), y * (size.y * 0.5 - 1))
			canvas.draw_polyline(PackedVector2Array([corner - Vector2(x * corner_length, 0), corner, corner - Vector2(0, y * corner_length)]), tint, 1, true)
	var arrow_length := minf(14, length * 0.16)
	var margin := minf(20, length * 0.28)
	var travel_length := maxf(1, length - margin * 2)
	var lanes := 3 if breadth < 180 else 4
	for i in range(lanes * (2 if power < 0.7 else 3)):
		var travel := fposmod(i * 37.0 + time * speed * signed_direction, travel_length)
		var across := lerpf(-breadth * 0.5 + minf(17, breadth * 0.25), breadth * 0.5 - minf(17, breadth * 0.25), float(i % lanes) / float(lanes - 1))
		var center := axis * (-length * 0.5 + margin + travel) + cross_axis * across
		var end := center + axis * arrow_length * 0.5 * signed_direction
		var rear := end - axis * minf(3, arrow_length * 0.35) * signed_direction
		canvas.draw_line(center - axis * arrow_length * 0.5 * signed_direction, end, tint, 1.2, true)
		canvas.draw_polyline(PackedVector2Array([rear - cross_axis * 2, end, rear + cross_axis * 2]), tint, 1.2, true)
	var radius := minf(9, minf(length, breadth) * 0.18)
	var fan := -axis * signed_direction * (length * 0.5 - radius - 3)
	canvas.draw_circle(fan, radius, Style.color("background", theme))
	canvas.draw_arc(fan, radius, 0, TAU, 24, tint, 1.5, true)
	for i in range(3):
		var angle := time * speed * 0.05 * signed_direction + i * TAU / 3.0
		canvas.draw_colored_polygon(PackedVector2Array([fan + Vector2.from_angle(angle) * radius * 0.2, fan + Vector2.from_angle(angle + 0.2) * radius * 0.75, fan + Vector2.from_angle(angle + 0.85) * radius * 0.6]), tint)
	canvas.draw_circle(fan, radius * 0.2, tint)

static func goal(canvas: Node2D, size: Vector2, theme: int, completed: bool) -> void:
	var tint := Style.color("warning", theme)
	var half := size * 0.5 - Vector2(2, 2)
	# Open arch, not a solid platform or circular teleporter. No text on the route.
	canvas.draw_polyline(PackedVector2Array([Vector2(-half.x, half.y), Vector2(-half.x, -half.y + 7), Vector2(-half.x + 7, -half.y), Vector2(half.x - 7, -half.y), Vector2(half.x, -half.y + 7), Vector2(half.x, half.y)]), tint, 2, true)
	for side in [-1, 1]:
		canvas.draw_line(Vector2(side * half.x, half.y), Vector2(side * (half.x - 8), half.y), tint, 2, true)
	# Small checkered finish ribbon integrated into the lintel.
	for column in range(6):
		for row in range(2):
			if (column + row) % 2 == 0:
				canvas.draw_rect(Rect2(-12 + column * 4, -half.y + 5 + row * 4, 4, 4), tint)
	if completed:
		canvas.draw_polyline(PackedVector2Array([Vector2(-6, 7), Vector2(-1, 12), Vector2(8, 2)]), tint, 2, true)
