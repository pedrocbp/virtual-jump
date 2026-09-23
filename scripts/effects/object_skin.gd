class_name WorldSkin
extends Node2D

const Design := preload("res://scripts/ui/design.gd")

var kind := "normal"
var dimensions := Vector2(100, 20)
var accent := Design.MINT
var vertical_movement := false
var _style: StyleBoxFlat
var _glow_time := 0.0

func _ready() -> void:
	_style = Design.box(Color("203c4b"), accent, 5)
	_style.shadow_color = Color(0.02, 0.04, 0.08, 0.6)
	_style.shadow_offset = Vector2(0, 4)
	_style.shadow_size = 2
	set_process(kind in ["temporary", "temporary_hazard", "block"])
	queue_redraw()

func _process(delta: float) -> void:
	_glow_time += delta
	queue_redraw()

func _draw() -> void:
	var rect := Rect2(-dimensions * 0.5, dimensions)
	if kind == "saw":
		for i in range(12):
			var angle := i * TAU / 12.0
			draw_colored_polygon(PackedVector2Array([Vector2.from_angle(angle) * 22, Vector2.from_angle(angle + 0.2) * 32, Vector2.from_angle(angle + 0.44) * 22]), accent)
		draw_circle(Vector2.ZERO, 23, Color("263949"))
		draw_arc(Vector2.ZERO, 21, 0, TAU, 48, accent, 2, true)
		draw_circle(Vector2.ZERO, 8, accent)
		draw_circle(Vector2.ZERO, 3, Design.INK)
		return
	if kind == "spike":
		_draw_blades()
		return
	if kind == "block":
		_draw_reactor()
		return
	_style.draw(get_canvas_item(), rect)
	draw_line(rect.position + Vector2(7, 2), Vector2(rect.end.x - 7, rect.position.y + 2), Color(accent, 0.9), 2, true)
	match kind:
		"moving":
			if vertical_movement:
				draw_polyline(PackedVector2Array([Vector2(-4, -2), Vector2(0, -5), Vector2(4, -2)]), accent, 1.5, true)
				draw_polyline(PackedVector2Array([Vector2(-4, 2), Vector2(0, 5), Vector2(4, 2)]), accent, 1.5, true)
			else:
				draw_polyline(PackedVector2Array([Vector2(-26, -4), Vector2(-31, 0), Vector2(-26, 4)]), accent, 1.5, true)
				draw_polyline(PackedVector2Array([Vector2(26, -4), Vector2(31, 0), Vector2(26, 4)]), accent, 1.5, true)
		"breakable":
			draw_polyline(PackedVector2Array([Vector2(-10, -8), Vector2(0, -2), Vector2(-4, 3), Vector2(7, 9)]), accent, 2, true)
		"temporary", "temporary_hazard":
			draw_arc(Vector2.ZERO, 5, -PI * 0.5, PI * 1.3, 24, accent, 1.5, true)
			draw_line(Vector2.ZERO, Vector2(0, -3), accent, 1.5, true)
			var object := get_parent().get_parent()
			var remaining := clampf(1.0 - float(object.get("_state_time")) / maxf(0.01, float(object.get("active_duration"))), 0, 1)
			draw_line(Vector2(rect.position.x + 6, rect.end.y - 3), Vector2(rect.position.x + 6 + (dimensions.x - 12) * remaining, rect.end.y - 3), accent, 2, true)
		"bar":
			for x in range(-40, 45, 14):
				draw_line(Vector2(x - 3, 4), Vector2(x + 3, -4), accent, 2, true)
		"small":
			draw_circle(Vector2.ZERO, 2, accent)

func _draw_blades() -> void:
	# Três lâminas facetadas ocupam o mesmo retângulo de perigo de 30 × 30.
	draw_colored_polygon(PackedVector2Array([Vector2(-15, 9), Vector2(-10, -8), Vector2(-3, 10)]), Color("b84c64"))
	draw_colored_polygon(PackedVector2Array([Vector2(3, 10), Vector2(11, -8), Vector2(15, 9)]), Color("b84c64"))
	draw_line(Vector2(-15, 9), Vector2(-10, -8), Color("ffa994"), 1, true)
	draw_line(Vector2(3, 10), Vector2(11, -8), Color("ffa994"), 1, true)
	draw_colored_polygon(PackedVector2Array([Vector2(-8, 10), Vector2(0, -15), Vector2(8, 10), Vector2(0, 13)]), Color("ff877e"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, -15), Vector2(8, 10), Vector2(0, 13)]), Color("be4660"))
	draw_line(Vector2(0, -13), Vector2(-6, 8), Color("fff0ce"), 1.5, true)
	draw_colored_polygon(PackedVector2Array([Vector2(-15, 10), Vector2(15, 10), Vector2(13, 15), Vector2(-13, 15)]), Color("293c4f"))
	draw_line(Vector2(-13, 11), Vector2(13, 11), Color("ff917f"), 1.3, true)
	draw_circle(Vector2(-10, 13), 1, Color("8dabbc"))
	draw_circle(Vector2(10, 13), 1, Color("8dabbc"))

func _draw_reactor() -> void:
	# Moldura chanfrada e núcleo luminoso: a carcaça inteira continua perigosa.
	var hull := PackedVector2Array([Vector2(-12, -16), Vector2(12, -16), Vector2(18, -10), Vector2(18, 10), Vector2(12, 16), Vector2(-12, 16), Vector2(-18, 10), Vector2(-18, -10)])
	draw_colored_polygon(hull, Color("913f59"))
	var face := PackedVector2Array([Vector2(-11, -13), Vector2(11, -13), Vector2(15, -9), Vector2(15, 9), Vector2(11, 13), Vector2(-11, 13), Vector2(-15, 9), Vector2(-15, -9)])
	draw_colored_polygon(face, Color("252e43"))
	draw_polyline(PackedVector2Array([Vector2(-17, -9), Vector2(-11, -15), Vector2(11, -15), Vector2(17, -9)]), Color("ffad98"), 1.5, true)
	draw_polyline(PackedVector2Array([Vector2(-17, 7), Vector2(-17, 10), Vector2(-12, 15)]), accent, 2, true)
	draw_polyline(PackedVector2Array([Vector2(17, 7), Vector2(17, 10), Vector2(12, 15)]), accent, 2, true)
	var pulse := 0.12 + 0.06 * sin(_glow_time * 2.4)
	draw_circle(Vector2.ZERO, 11, Color(1.0, 0.4, 0.4, pulse))
	draw_colored_polygon(PackedVector2Array([Vector2(0, -8), Vector2(7, 0), Vector2(0, 8), Vector2(-7, 0)]), Color("ff786e"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, -5), Vector2(4, 0), Vector2(0, 5), Vector2(-4, 0)]), Color("ffe4bd"))
	for side in [-1, 1]:
		draw_line(Vector2(side * 11, -3), Vector2(side * 11, 3), Color("ff987f"), 1.5, true)

static func apply_to_tree(root: Node) -> void:
	for child in root.get_children():
		apply_to_tree(child)
	var visual := root.get_node_or_null("Visual") as Polygon2D
	if visual == null or visual.has_node("Skin"):
		return
	var collision := root.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null:
		return
	var skin := WorldSkin.new()
	skin.name = "Skin"
	if collision.shape is RectangleShape2D:
		skin.dimensions = collision.shape.size
	if root is MovingPlatform:
		skin.kind = "moving"
		skin.accent = Color("80caff")
		skin.vertical_movement = absf(root.movement_axis.y) > absf(root.movement_axis.x)
	elif root is BreakablePlatform:
		skin.kind = "breakable"
		skin.accent = Color("ffbd82")
	elif root is TemporaryPlatform:
		skin.kind = "temporary"
		skin.accent = Color("c5a1ff")
	elif root is MovingSaw:
		skin.kind = "saw"
		skin.accent = Design.CORAL
	elif root is MovingBar:
		skin.kind = "bar"
		skin.accent = Design.CORAL
	elif root is TemporaryHazard:
		skin.kind = "temporary_hazard"
		skin.accent = Design.CORAL
	elif root is Hazard:
		skin.kind = "spike" if root.get_script().resource_path.ends_with("spike.gd") else "block"
		skin.accent = Design.CORAL
	elif root.name == "Goal":
		skin.kind = "goal"
		skin.accent = Design.GOLD
		var caption := root.get_node("Label") as Label
		caption.text = "↑  CHEGADA"
		caption.add_theme_color_override("font_color", Design.GOLD)
	elif skin.dimensions.x < 90:
		skin.kind = "small"
	visual.polygon = PackedVector2Array()
	visual.add_child(skin)
	# Ornamentos antigos são substituídos juntos, acompanhando o estado do Visual.
	for decoration in ["CrackOne", "Signal", "Highlight", "Core", "Warning", "IndicatorLeft", "IndicatorRight", "CenterMark"]:
		var node := root.get_node_or_null(decoration) as CanvasItem
		if node != null:
			node.hide()
