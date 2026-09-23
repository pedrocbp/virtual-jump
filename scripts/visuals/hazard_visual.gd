extends Node2D
## State-aware drawing only. Source owns clocks, collision and damage.
const Style := preload("res://scripts/visuals/world_style.gd")
const Shapes := preload("res://scripts/visuals/hazard_shapes.gd")
var source: Node2D
var inactive_only := false
var _last: Dictionary = {}
var _theme := -1

static func install(body: Node2D, inactive_marker := false) -> void:
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
	skin.set_script(load("res://scripts/visuals/hazard_visual.gd"))
	skin.name = "Skin"
	skin.source = body
	visual.add_child(skin)
	var old_signal := body.get_node_or_null("Signal") as CanvasItem
	if old_signal != null:
		old_signal.hide()
	if inactive_marker:
		var marker := Node2D.new()
		marker.set_script(load("res://scripts/visuals/hazard_visual.gd"))
		marker.source = body
		marker.inactive_only = true
		marker.name = "InactiveVisual"
		body.add_child(marker)

static func refresh(body: Node2D) -> void:
	for path in ["Visual/Skin", "InactiveVisual"]:
		var visual := body.get_node_or_null(path) as CanvasItem
		if visual != null:
			visual.queue_redraw()

func _process(_delta: float) -> void:
	var snapshot: Dictionary = source.get_visual_state()
	var theme := Style.theme_for(self)
	if snapshot != _last or theme != _theme:
		_last = snapshot
		_theme = theme
		if is_visible_in_tree():
			queue_redraw()

func _draw() -> void:
	var snapshot: Dictionary = source.get_visual_state()
	var size: Vector2 = source.get_node("CollisionShape2D").shape.size
	var theme := Style.theme_for(self)
	match snapshot.kind:
		"temporary_hazard":
			if inactive_only == bool(snapshot.deadly):
				return
			Shapes.timed_block(self, size, snapshot, theme)
		"retractable":
			Shapes.retractable(self, size, snapshot, theme)
		"laser":
			Shapes.laser(self, size, snapshot, theme)
