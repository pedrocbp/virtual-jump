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
		draw_circle(center, 29, Color(Design.MINT, 0.12))
		draw_arc(center, 28, 0, TAU, 40, Design.MINT, 1.5, true)
	Skins.draw_ball(self, center, 19, skin_id)
	if locked:
		draw_circle(center, 22, Color(Design.INK, 0.58))
		draw_string(ThemeDB.fallback_font, center + Vector2(-5, 6), "×", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Design.MUTED)
