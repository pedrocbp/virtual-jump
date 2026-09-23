extends RefCounted
const Style := preload("res://scripts/visuals/world_style.gd")
static var _styles: Dictionary = {}

static func _plate(canvas: Node2D, rect: Rect2, role: String, theme: int) -> void:
	var key := "%s:%d" % [role, theme]
	if not _styles.has(key):
		_styles[key] = Style.plate_style(theme, role)
	canvas.draw_style_box(_styles[key], rect)
	if theme == 0:
		canvas.draw_line(rect.position + Vector2(6, 2), Vector2(rect.end.x - 6, rect.position.y + 2), Style.color(role, theme).lerp(Color.WHITE, 0.55), 1, true)

static func _chevron(canvas: Node2D, center: Vector2, axis: Vector2, size: float, color: Color) -> void:
	var perpendicular := axis.orthogonal()
	canvas.draw_polyline(PackedVector2Array([center - axis * size * 0.5 + perpendicular * size, center + axis * size * 0.5, center - axis * size * 0.5 - perpendicular * size]), color, 1.6, true)

static func draw_platform(canvas: Node2D, size: Vector2, state: Dictionary, theme: int) -> void:
	var kind: String = state.kind
	var rect := Rect2(-size * 0.5, size)
	var ink := Style.color("ink", theme)
	var role := "fragile"
	if kind in ["moving", "impulse"]:
		role = "flow"
	elif kind == "temporary":
		role = "portal"
	elif kind == "spring":
		role = "spring"
	var tint := Style.color(role, theme)
	if not state.get("active", true):
		# No filled face and no continuous landing edge while intangible.
		var readiness: float = state.get("progress", 0.0)
		for side in [-1, 1]:
			var x: float = side * (size.x * 0.5 - 2)
			canvas.draw_line(Vector2(x, -3), Vector2(x, 3), tint, 1, true)
		for i in range(5):
			var x := -size.x * 0.35 + i * size.x * 0.175
			canvas.draw_line(Vector2(x - 2, 0), Vector2(x + 2, 0), tint, 1, true)
		if readiness > 0.7:
			canvas.draw_arc(Vector2.ZERO, 5, -PI * 0.5, -PI * 0.5 + TAU * (readiness - 0.7) / 0.3, 24, tint, 1.3, true)
		return
	if kind == "crumbling" and state.get("state", "stable") == "falling":
		# Broken pieces, not an unbroken-looking support with no collision.
		for i in range(4):
			var x := rect.position.x + i * size.x * 0.25
			_plate(canvas, Rect2(x + 2, -7 + (i % 2) * 5, size.x * 0.25 - 4, 12), role, theme)
		return
	_plate(canvas, rect, role, theme)
	match kind:
		"moving":
			var axis: Vector2 = state.get("axis", Vector2.RIGHT)
			var offset: float = state.get("offset", 0.0)
			var track_half := 5.0 if absf(axis.y) > 0.5 else 16.0
			canvas.draw_line(-axis * track_half, axis * track_half, ink, 1.5, true)
			canvas.draw_circle(axis * offset * track_half, 2.5, ink)
			if absf(axis.y) > 0.5:
				_chevron(canvas, Vector2(-12, 0), Vector2.UP, 3, ink)
				_chevron(canvas, Vector2(12, 0), Vector2.DOWN, 3, ink)
			else:
				_chevron(canvas, Vector2(-25, 0), -axis, 3.5, ink)
				_chevron(canvas, Vector2(25, 0), axis, 3.5, ink)
			for side in [-1, 1]:
				canvas.draw_line(Vector2(side * (size.x * 0.5 - 6), -3), Vector2(side * (size.x * 0.5 - 6), 3), ink, 2, true)
		"breakable":
			var progress: float = state.get("progress", 0.0)
			var seam := PackedVector2Array([Vector2(-3, -8), Vector2(3, -2), Vector2(-2, 3), Vector2(3, 8)])
			canvas.draw_polyline(seam, ink, 1.5 + progress * 3.0, true)
			for side in [-1, 1]:
				canvas.draw_line(Vector2(side * 13, 0), Vector2(side * (19 + progress * 4), 0), ink, 2, true)
		"crumbling":
			var total: int = state.get("total", 4)
			var hits: int = state.get("hits", 0)
			var spacing := minf(12, (size.x - 16) / float(total))
			for i in range(total):
				var x: float = (i - (total - 1) * 0.5) * spacing
				var mark := Rect2(x - 3, 3, 6, 3)
				var filled := i < total - hits
				canvas.draw_rect(mark, ink, filled, -1 if filled else 1)
			for i in range(mini(hits, 4)):
				var x := -size.x * 0.32 + i * size.x * 0.21
				canvas.draw_polyline(PackedVector2Array([Vector2(x, -9), Vector2(x + 4, -5), Vector2(x, 0)]), ink, 1.5, true)
			if hits == total - 1:
				canvas.draw_line(Vector2(-4, -8), Vector2(4, -8), ink, 2, true)
		"falling":
			var progress: float = state.get("progress", 0.0)
			var jitter := sin(progress * 22) * progress if state.get("state", "stable") == "shaking" else 0.0
			for side in [-1, 1]:
				var x: float = side * size.x * 0.32
				canvas.draw_polyline(PackedVector2Array([Vector2(x - 4, -6), Vector2(x - 4, -1 + progress * 3), Vector2(x + 4, -1 + progress * 3), Vector2(x + 4, -6)]), ink, 1.5, true)
			_chevron(canvas, Vector2(jitter, 0), Vector2.DOWN, 4, ink)
			canvas.draw_line(Vector2(-8, 6), Vector2(8, 6), ink, 1.5, true)
		"temporary":
			var remaining: float = 1.0 - state.get("progress", 0.0)
			for i in range(5):
				var x := -size.x * 0.4 + i * size.x * 0.2
				var filled := remaining > i * 0.2
				canvas.draw_rect(Rect2(x - 4, -2, 8, 4), ink, filled, -1 if filled else 1)
				if i > 0:
					canvas.draw_line(Vector2(x - size.x * 0.1, 3), Vector2(x - size.x * 0.1, 8), ink, 1, true)
		"spring":
			var pulse: float = state.get("pulse", 0.0)
			# The top remains fixed. Only the internal spring compresses.
			var top := -6.0 + pulse * 4.0
			canvas.draw_rect(Rect2(-13, -7, 26, 2), ink)
			canvas.draw_line(Vector2(-12, 7), Vector2(12, 7), ink, 1.5, true)
			var coil := PackedVector2Array([Vector2(0, top)])
			for i in range(5):
				coil.append(Vector2(-7 if i % 2 == 0 else 7, lerpf(top, 6, (i + 1) / 6.0)))
			coil.append(Vector2(0, 6))
			canvas.draw_polyline(coil, ink, 1.5, true)
			for side in [-1, 1]:
				_chevron(canvas, Vector2(side * 29, 0), Vector2.UP, 4, ink)
			if pulse > 0.01:
				for x in [-20, 20]:
					var y := -size.y * 0.5 - 3 - (1 - pulse) * 14
					canvas.draw_line(Vector2(x, y), Vector2(x, y - 4), tint, 1, true)
		"impulse":
			var direction := Vector2(float(state.get("direction", 1)), 0)
			var phase: float = state.get("phase", 0.0)
			var pulse: float = state.get("pulse", 0.0)
			for side in [-1, 1]:
				_chevron(canvas, Vector2(side * 16, -1), direction, 4.5, ink)
			for i in range(7):
				var x := -size.x * 0.4 + fposmod(i * size.x * 0.12 + phase * 12 * direction.x, size.x * 0.8)
				canvas.draw_line(Vector2(x, 6), Vector2(x + 3, 6), ink, 1.5, true)
			if pulse > 0.01:
				canvas.draw_line(Vector2(-size.x * 0.38, -size.y * 0.5 + 3), Vector2(-size.x * 0.38 + size.x * 0.76 * pulse, -size.y * 0.5 + 3), ink, 1.5, true)
