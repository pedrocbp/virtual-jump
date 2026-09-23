class_name SpringPlatform
extends StaticBody2D

const Design := preload("res://scripts/ui/design.gd")

# Impulso suficiente para atravessar cerca de tres intervalos normais.
@export var spring_force: float = 1080.0
var _pulse := 0.0

func _ready() -> void:
	add_to_group("attempt_resettable")
	queue_redraw()

func on_player_landed() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	player.apply_vertical_boost(spring_force)
	_pulse = 1.0
	var feedback := get_node_or_null("/root/Feedback")
	if feedback != null:
		feedback.play_sound("win")
		feedback.vibrate(12)
	queue_redraw()

func _process(delta: float) -> void:
	_pulse = move_toward(_pulse, 0.0, delta * 5.0)
	queue_redraw()

func reset_attempt() -> void:
	_pulse = 0.0
	queue_redraw()

func _draw() -> void:
	var squash := 1.0 - _pulse * 0.16
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, squash))
	draw_style_box(Design.box(Color("e56b3f"), Color("ffd18a"), 6), Rect2(-50, -10, 100, 20))
	for x in [-28.0, -9.0, 10.0, 29.0]:
		draw_line(Vector2(x - 6, 2), Vector2(x, -4), Color("fff0c2"), 2.0, true)
		draw_line(Vector2(x, -4), Vector2(x + 6, 2), Color("fff0c2"), 2.0, true)
