extends Node2D
## A read-only visual child. Gameplay exports an explicit snapshot; this node
## never controls collision, transforms, timers, impulses or landing counts.
const Style := preload("res://scripts/visuals/world_style.gd")
const Shapes := preload("res://scripts/visuals/platform_shapes.gd")

var source: Node2D
var ghost_only := false
var _last_snapshot: Dictionary = {}
var _last_theme := -1

static func install(body: Node2D, include_ghost := false) -> void:
	var visual := body.get_node_or_null("Visual") as Node2D
	if visual == null:
		visual = Node2D.new()
		visual.name = "Visual"
		body.add_child(visual)
	if visual.has_node("Skin"):
		return
	if visual is Polygon2D:
		visual.polygon = PackedVector2Array()
	var skin := Node2D.new()
	skin.set_script(load("res://scripts/visuals/platform_visual.gd"))
	skin.name = "Skin"
	skin.source = body
	visual.add_child(skin)
	for decoration in ["CrackOne", "IndicatorLeft", "IndicatorRight"]:
		var old := body.get_node_or_null(decoration) as CanvasItem
		if old != null:
			old.hide()
	if include_ghost:
		var ghost := Node2D.new()
		ghost.set_script(load("res://scripts/visuals/platform_visual.gd"))
		ghost.name = "InactiveVisual"
		ghost.source = body
		ghost.ghost_only = true
		body.add_child(ghost)

static func refresh(body: Node2D) -> void:
	for path in ["Visual/Skin", "InactiveVisual"]:
		var visual := body.get_node_or_null(path) as CanvasItem
		if visual != null:
			visual.queue_redraw()

func _process(_delta: float) -> void:
	var snapshot: Dictionary = source.get_visual_state()
	var theme := Style.theme_for(self)
	if snapshot != _last_snapshot or theme != _last_theme:
		_last_snapshot = snapshot
		_last_theme = theme
		if is_visible_in_tree():
			queue_redraw()

func _draw() -> void:
	if not is_instance_valid(source):
		return
	var snapshot: Dictionary = source.get_visual_state()
	var is_active: bool = snapshot.get("active", true)
	if ghost_only == is_active:
		return
	var collision := source.get_node("CollisionShape2D") as CollisionShape2D
	var shape := collision.shape as RectangleShape2D
	Shapes.draw_platform(self, shape.size, snapshot, Style.theme_for(self))
