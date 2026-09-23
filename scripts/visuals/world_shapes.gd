extends RefCounted
const Style := preload("res://scripts/visuals/world_style.gd")
static var _plates: Dictionary = {}
static var _saw_polygons: Dictionary = {}

static func plate(canvas: Node2D, size: Vector2, theme: int) -> void:
	if not _plates.has(theme):
		_plates[theme] = Style.plate_style(theme)
	var rect := Rect2(-size * 0.5, size)
	canvas.draw_style_box(_plates[theme], rect)
	# All details stay inside the physical support; no fake ledge.
	canvas.draw_line(Vector2(rect.position.x + 6, rect.end.y - 4), Vector2(rect.end.x - 6, rect.end.y - 4), Style.color("ink", theme), 1.5, true)
	if theme == 0:
		canvas.draw_line(rect.position + Vector2(6, 2), Vector2(rect.end.x - 6, rect.position.y + 2), Color("c4ffe3"), 1, true)

static func spike(canvas: Node2D, size: Vector2, theme: int, blades := 3) -> void:
	var half := size * 0.5
	var danger := Style.color("danger", theme)
	var ink := Style.color("ink", theme)
	# Production silhouette used before the crystal study: regular triangular
	# blades over a compact base. Collision and gameplay dimensions stay intact.
	var base_height := minf(6.0, size.y * 0.24)
	var base_top := half.y - base_height
	canvas.draw_rect(Rect2(Vector2(-half.x, base_top), Vector2(size.x, base_height)), danger)
	var pitch := size.x / float(blades)
	for i in range(blades):
		var center_x := -half.x + (float(i) + 0.5) * pitch
		var blade := PackedVector2Array([
			Vector2(center_x - pitch * 0.46, base_top),
			Vector2(center_x, -half.y),
			Vector2(center_x + pitch * 0.46, base_top),
		])
		canvas.draw_colored_polygon(blade, danger)
	canvas.draw_line(Vector2(-half.x, base_top), Vector2(half.x, base_top), ink, 1.5, true)

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
