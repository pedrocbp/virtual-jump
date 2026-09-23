extends RefCounted
const Style := preload("res://scripts/visuals/world_style.gd")
const World := preload("res://scripts/visuals/world_shapes.gd")
static var _hulls: Dictionary = {}

static func _hull(size: Vector2) -> PackedVector2Array:
	if not _hulls.has(size):
		var h := size * 0.5
		var cut := minf(3, minf(h.x, h.y) * 0.2)
		_hulls[size] = PackedVector2Array([Vector2(-h.x + cut, -h.y), Vector2(h.x - cut, -h.y), Vector2(h.x, -h.y + cut), Vector2(h.x, h.y - cut), Vector2(h.x - cut, h.y), Vector2(-h.x + cut, h.y), Vector2(-h.x, h.y - cut), Vector2(-h.x, -h.y + cut)])
	return _hulls[size]

static func block(canvas: Node2D, size: Vector2, theme: int, time := 0.0) -> void:
	var tint := Style.color("danger", theme)
	var ink := Style.color("ink", theme)
	canvas.draw_colored_polygon(_hull(size), tint)
	var radius := minf(size.x, size.y) * 0.27
	var core := PackedVector2Array([Vector2(0, -radius), Vector2(radius, 0), Vector2(0, radius), Vector2(-radius, 0), Vector2(0, -radius)])
	canvas.draw_polyline(core, ink, 2, true)
	# The lethal silhouette never pulses, fades, or suggests an off window.
	var core_size := 2.0 + sin(time * 2.2) * 0.35
	canvas.draw_rect(Rect2(Vector2.ONE * -core_size, Vector2.ONE * core_size * 2), ink)
	for side in [-1, 1]:
		var x: float = side * (size.x * 0.5 - 4)
		canvas.draw_line(Vector2(x, -4), Vector2(x, 4), ink, 1.5, true)

static func bar(canvas: Node2D, size: Vector2, theme: int) -> void:
	var ink := Style.color("ink", theme)
	canvas.draw_colored_polygon(_hull(size), Style.color("danger", theme))
	# Diagonal cuts + pointed end caps; no landing highlight or motion arrows.
	var left := -size.x * 0.5 + 13
	var right := size.x * 0.5 - 13
	var count := maxi(1, int((right - left) / 13.0))
	for i in range(count + 1):
		var x := lerpf(left, right, i / float(maxi(1, count)))
		canvas.draw_line(Vector2(x - 3, size.y * 0.5 - 3), Vector2(x + 3, -size.y * 0.5 + 3), ink, 3, true)
	for side in [-1, 1]:
		var x: float = side * (size.x * 0.5 - 4)
		canvas.draw_polyline(PackedVector2Array([Vector2(x, -size.y * 0.5 + 3), Vector2(x - side * 4, 0), Vector2(x, size.y * 0.5 - 3)]), ink, 2, true)

static func _brackets(canvas: Node2D, size: Vector2, tint: Color, progress: float) -> void:
	var h := size * 0.5 - Vector2.ONE
	var length := lerpf(3, minf(h.x, h.y) * 0.7, clampf(progress, 0, 1))
	for x in [-1, 1]:
		for y in [-1, 1]:
			var corner := Vector2(x * h.x, y * h.y)
			canvas.draw_polyline(PackedVector2Array([corner - Vector2(x * length, 0), corner, corner - Vector2(0, y * length)]), tint, 1.5, true)

static func timed_block(canvas: Node2D, size: Vector2, snapshot: Dictionary, theme: int) -> void:
	var state: String = snapshot.state
	var progress: float = snapshot.progress
	var tint := Style.color("danger" if state == "active" else "warning", theme)
	if state != "active":
		_brackets(canvas, size, tint, progress if state == "warning" else 0.0)
		if state == "warning":
			canvas.draw_line(Vector2(0, -5), Vector2(0, 1), tint, 2, true)
			canvas.draw_circle(Vector2(0, 5), 1, tint)
		return
	block(canvas, size, theme)
	var ink := Style.color("ink", theme)
	var left := -size.x * 0.5 + 5
	var right := size.x * 0.5 - 5
	for i in range(4):
		var x := lerpf(left, right, i / 3.0)
		if progress < (i + 1) * 0.25:
			canvas.draw_line(Vector2(x - 2, size.y * 0.5 - 3), Vector2(x + 2, size.y * 0.5 - 3), ink, 1.5, true)

static func retractable(canvas: Node2D, size: Vector2, snapshot: Dictionary, theme: int) -> void:
	if snapshot.state == "active":
		World.spike(canvas, size, theme, 4)
		return
	var tint := Style.color("warning", theme)
	var y := size.y * 0.5 - 3
	for i in range(4):
		var x := -size.x * 0.5 + (i + 0.5) * size.x / 4.0
		canvas.draw_line(Vector2(x - 5, y), Vector2(x + 5, y), tint, 1.5, true)
		if snapshot.state == "warning":
			var height: float = 2 + float(snapshot.progress) * 4
			# Short hollow points, not the full lethal blades.
			canvas.draw_polyline(PackedVector2Array([Vector2(x - 3, y - 2), Vector2(x, y - 2 - height), Vector2(x + 3, y - 2)]), tint, 1.5, true)
	if snapshot.state == "warning":
		canvas.draw_line(Vector2(-size.x * 0.5 + 2, size.y * 0.5 - 1), Vector2(-size.x * 0.5 + 2 + (size.x - 4) * float(snapshot.progress), size.y * 0.5 - 1), tint, 1, true)

static func laser(canvas: Node2D, size: Vector2, snapshot: Dictionary, theme: int) -> void:
	var active: bool = snapshot.state == "active"
	var warning: bool = snapshot.state == "warning"
	var tint := Style.color("danger" if active else "warning", theme)
	var half := size.x * 0.5
	if active:
		# Exactly the physical lethal width/height. Emitters are ornaments.
		canvas.draw_rect(Rect2(-size * 0.5, size), tint)
		canvas.draw_line(Vector2(-half, 0), Vector2(half, 0), Style.color("highlight" if theme == 0 else "ink", theme), 1, true)
	else:
		var spacing := 10.0 if warning else 20.0
		var count := maxi(1, int(size.x / spacing))
		for i in range(count):
			var x := -half + (i + 0.5) * size.x / count
			var length := 4.0 if warning else 1.0
			canvas.draw_line(Vector2(x - length * 0.5, 0), Vector2(x + length * 0.5, 0), tint, 1.5 if warning else 1.0, true)
	for side in [-1, 1]:
		var x: float = side * (half + 4)
		# Open-ended brackets distinguish nonlethal housings from the beam.
		canvas.draw_polyline(PackedVector2Array([Vector2(x - side * 2, -8), Vector2(x + side * 2, -8), Vector2(x + side * 2, 8), Vector2(x - side * 2, 8)]), tint, 1.5, true)
		if warning:
			var height := 12 * float(snapshot.progress)
			canvas.draw_line(Vector2(x, 6), Vector2(x, 6 - height), tint, 2, true)
		elif active:
			canvas.draw_line(Vector2(x, -5), Vector2(x, 5), tint, 2, true)
