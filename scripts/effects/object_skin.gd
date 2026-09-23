class_name WorldSkin
extends Node2D

const Design := preload("res://scripts/ui/design.gd")
const HazardShapes := preload("res://scripts/visuals/hazard_shapes.gd")
const Shapes := preload("res://scripts/visuals/world_shapes.gd")
const WorldStyle := preload("res://scripts/visuals/world_style.gd")

var kind := "normal"
var dimensions := Vector2(100, 20)
var accent := Design.MINT
var collision_radius := 25.0
var finish_source: Node
var _style: StyleBoxFlat
var _glow_time := 0.0

func _ready() -> void:
	if kind not in ["normal", "small", "saw", "spike", "block", "bar", "goal"]:
		_style = Design.box(Color("203c4b"), accent, 5)
		_style.shadow_color = Color(0.02, 0.04, 0.08, 0.6)
		_style.shadow_offset = Vector2(0, 4)
		_style.shadow_size = 2
	set_process(kind == "block")
	queue_redraw()

func _process(delta: float) -> void:
	_glow_time += delta
	queue_redraw()

func _draw() -> void:
	var theme := WorldStyle.theme_for(self)
	match kind:
		"normal", "small":
			Shapes.plate(self, dimensions, theme)
		"saw":
			Shapes.saw(self, collision_radius, theme)
		"spike":
			Shapes.spike(self, dimensions, theme)
		"block":
			HazardShapes.block(self, dimensions, theme, _glow_time)
		"bar":
			HazardShapes.bar(self, dimensions, theme)
		"goal":
			preload("res://scripts/visuals/flow_shapes.gd").goal(self, dimensions, theme, finish_source.get_finish_visual_state())
		_:
			var rect := Rect2(-dimensions * 0.5, dimensions)
			_style.draw(get_canvas_item(), rect)
			draw_line(rect.position + Vector2(7, 2), Vector2(rect.end.x - 7, rect.position.y + 2), Color(accent, 0.9), 2, true)

func reset_visual() -> void:
	_glow_time = 0
	queue_redraw()

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
	elif collision.shape is CircleShape2D:
		skin.collision_radius = collision.shape.radius
	if root is MovingSaw:
		skin.kind = "saw"
		skin.accent = Design.CORAL
	elif root is MovingBar:
		skin.kind = "bar"
		skin.accent = Design.CORAL
	elif root is Hazard:
		skin.kind = "spike" if root.get_script().resource_path.ends_with("spike.gd") else "block"
		skin.accent = Design.CORAL
	elif root.has_method("get_finish_visual_state"):
		skin.kind = "goal"
		skin.finish_source = root
		skin.accent = Design.GOLD
		var caption := root.get_node("Label") as Label
		caption.hide()
	elif skin.dimensions.x < 90:
		skin.kind = "small"
	visual.polygon = PackedVector2Array()
	visual.add_child(skin)
	# Ornamentos antigos são substituídos juntos, acompanhando o estado do Visual.
	for decoration in ["CrackOne", "Signal", "Highlight", "Core", "Warning", "IndicatorLeft", "IndicatorRight", "CenterMark"]:
		var node := root.get_node_or_null(decoration) as CanvasItem
		if node != null:
			node.hide()
