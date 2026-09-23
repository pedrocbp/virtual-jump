class_name EndlessMilestone
extends Node2D

const Design := preload("res://scripts/ui/design.gd")

var block_value := 25

func _ready() -> void:
	z_index = -2
	var caption := Design.label("↑  %d BLOCOS" % block_value, 12, Design.GOLD)
	caption.position = Vector2(110, -30)
	caption.size = Vector2(140, 22)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caption)
	queue_redraw()

func _draw() -> void:
	for x in range(20, 340, 18):
		draw_line(Vector2(x, 0), Vector2(mini(x + 9, 340), 0), Design.native_color(Color(Design.GOLD, 0.36)), 1.0, true)
	draw_circle(Vector2(12, 0), 3.0, Design.native_color(Design.GOLD))
	draw_circle(Vector2(348, 0), 3.0, Design.native_color(Design.GOLD))
