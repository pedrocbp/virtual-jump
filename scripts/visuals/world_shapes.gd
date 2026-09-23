extends RefCounted
const Style := preload("res://scripts/visuals/world_style.gd")
static var _plates: Dictionary = {}
static var _saw_polygons: Dictionary = {}

static func plate(canvas: Node2D, size: Vector2, theme: int) -> void:
	if not _plates.has(theme):
		var legacy := StyleBoxFlat.new()
		legacy.bg_color = Style.color("surface", theme)
		legacy.border_color = Style.color("support", theme)
		legacy.set_border_width_all(1)
		legacy.set_corner_radius_all(5)
		legacy.anti_aliasing = true
		if theme == 0:
			legacy.shadow_color = Color(0.01, 0.025, 0.045, 0.28)
			legacy.shadow_offset = Vector2(0, 2)
			legacy.shadow_size = 1
		_plates[theme] = legacy
	var rect := Rect2(-size * 0.5, size)
	canvas.draw_style_box(_plates[theme], rect)
	# Legacy v1 accent: one restrained highlight near the upper edge.
	canvas.draw_line(rect.position + Vector2(7, 2), Vector2(rect.end.x - 7, rect.position.y + 2), Style.color("support", theme), 1.8, true)

static func spike(canvas: Node2D, size: Vector2, theme: int, blades := 3) -> void:
	var half := size * 0.5
	var danger := Style.color("danger", theme)
	var ink := Style.color("ink", theme)
	# Legacy production silhouette from visual-v1: a compact danger block with
	# three clear internal blades. Only rendering changes; collision is untouched.
	var rect := Rect2(-half, size)
	canvas.draw_rect(rect, Color(danger, 0.12))
	canvas.draw_polyline(PackedVector2Array([
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y), Vector2(-half.x, -half.y),
	]), danger, 1.25, true)
	var pitch := size.x / float(blades)
	for i in range(blades):
		var center_x := -half.x + (float(i) + 0.5) * pitch
		var blade := PackedVector2Array([
			Vector2(center_x - pitch * 0.42, half.y - 1.0),
			Vector2(center_x, -half.y + (7.0 if i == 1 else 10.0)),
			Vector2(center_x + pitch * 0.42, half.y - 1.0),
		])
		canvas.draw_colored_polygon(blade, danger)
		canvas.draw_polyline(blade, ink, 0.9, true)
	canvas.draw_line(Vector2(-half.x + 3, half.y - 1), Vector2(half.x - 3, half.y - 1), ink, 1.2, true)

static func saw(canvas: Node2D, radius: float, theme: int) -> void:
	if not _saw_polygons.has(radius):
		var contour := PackedVector2Array()
		for i in range(12):
			var angle := i * TAU / 12.0
			contour.append(Vector2.from_angle(angle) * radius * 0.87)
			contour.append(Vector2.from_angle(angle + 0.15) * radius)
			contour.append(Vector2.from_angle(angle + 0.41) * radius)
			contour.append(Vector2.from_angle(angle + 0.49) * radius * 0.87)
		_saw_polygons[radius] = contour
	var danger := Style.color("danger", theme)
	var ink := Style.color("ink", theme)
	canvas.draw_colored_polygon(_saw_polygons[radius], danger)
	canvas.draw_arc(Vector2.ZERO, radius * 0.66, 0, TAU, 48, ink, 1.5, true)
	canvas.draw_circle(Vector2.ZERO, radius * 0.27, ink)
	canvas.draw_circle(Vector2.ZERO, radius * 0.105, danger)
	for i in range(3):
		var direction := Vector2.from_angle(i * TAU / 3.0)
		canvas.draw_line(direction * radius * 0.38, direction * radius * 0.52, ink, 2.0, true)

static func wind(canvas: Node2D, size: Vector2, direction: int, strength: float, time: float, theme: int) -> void:
	preload("res://scripts/visuals/flow_shapes.gd").wind(canvas, size, direction, strength, time, theme)

static func portal(canvas: Node2D, radius: float, entry: bool, time: float, warning: float, remaining: float, theme: int, original_color := Color.TRANSPARENT) -> void:
	var tint := Style.color("portal" if entry else "flow", theme)
	if theme == 0 and original_color.a > 0:
		tint = original_color
	if warning >= 0:
		# Only a partial outline during warning; never a usable-looking ring.
		if warning > 0:
			canvas.draw_arc(Vector2.ZERO, radius - 1, -PI * 0.5, -PI * 0.5 + TAU * warning * 0.85, 40, tint, 1.2, true)
		return
	canvas.draw_arc(Vector2.ZERO, radius - 1, 0, TAU, 64, tint, 2.0, true)
	for i in range(3):
		var angle := time * (0.6 if entry else -0.4) + i * TAU / 3.0
		canvas.draw_arc(Vector2.ZERO, radius * 0.72, angle, angle + 0.65, 12, tint, 1.5, true)
		var axis := Vector2.from_angle(angle + 0.32)
		var tangent := axis.orthogonal()
		var center := axis * radius * 0.47
		var tip := center + axis * (-2.5 if entry else 2.5)
		var rear := center - axis * (-2.5 if entry else 2.5)
		canvas.draw_polyline(PackedVector2Array([rear + tangent * 2.5, tip, rear - tangent * 2.5]), tint, 1.5, true)
	if remaining >= 0:
		canvas.draw_arc(Vector2.ZERO, radius + 3, -PI * 0.5, -PI * 0.5 + TAU * maxf(0.001, remaining), 48, tint, 1, true)
