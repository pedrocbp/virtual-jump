extends Button
## Same 22-unit optical box, independent of system fonts. Hit target is 44x44.
const Style := preload("res://scripts/visuals/world_style.gd")
var icon_kind := "pause"

func _ready() -> void:
	custom_minimum_size = Vector2(44, 44)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed", "focus"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	resized.connect(queue_redraw)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)

func _draw() -> void:
	var center := size * 0.5
	var tint := Style.color("highlight", Style.theme_for(self))
	if is_pressed():
		tint.a = 0.6
	match icon_kind:
		"pause":
			for x in [-5, 5]:
				draw_line(center + Vector2(x, -10), center + Vector2(x, 10), tint, 3, true)
		"restart":
			draw_arc(center, 9, -PI * 0.3, PI * 1.35, 32, tint, 2.2, true)
			var tip := center + Vector2.from_angle(PI * 1.35) * 9
			draw_polyline(PackedVector2Array([tip + Vector2(-4, 1), tip, tip + Vector2(1, 4)]), tint, 2.2, true)
		"settings":
			draw_arc(center, 7, 0, TAU, 32, tint, 2, true)
			draw_arc(center, 2.5, 0, TAU, 20, tint, 1.5, true)
			for i in range(8):
				var axis := Vector2.from_angle(i * TAU / 8.0)
				draw_line(center + axis * 7, center + axis * 10, tint, 2.5, true)
