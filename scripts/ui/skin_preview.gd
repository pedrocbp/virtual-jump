class_name SkinPreview
extends Control

const Skins := preload("res://scripts/systems/skin_catalog.gd")
const Design := preload("res://scripts/ui/design.gd")

var skin_id := "classic"
var selected := false
var locked := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(66, 66)
	queue_redraw()

func configure(new_skin_id: String, is_selected: bool, is_locked: bool) -> void:
	skin_id = new_skin_id
	selected = is_selected
	locked = is_locked
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	if selected:
		draw_arc(center, 28, 0, TAU, 40, Design.native_color(Design.MINT), 1.5, true)
	Skins.draw_ball(self, center, 19, skin_id)
	if locked:
		# Keep the skin readable; lock is a small separate symbol below it.
		var tint := Design.native_color(Design.MUTED)
		draw_arc(center + Vector2(0, 24), 3, PI, TAU, 12, tint, 1, true)
		draw_rect(Rect2(center + Vector2(-4, 24), Vector2(8, 5)), tint)
