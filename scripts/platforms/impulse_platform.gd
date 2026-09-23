class_name ImpulsePlatform
extends StaticBody2D

const Design := preload("res://scripts/ui/design.gd")

@export_range(-1, 1, 2) var direction: int = 1
@export_range(220.0, 330.0, 5.0) var impulse_speed: float = 300.0

var _pulse := 0.0

func _ready() -> void:
	add_to_group("attempt_resettable")
	queue_redraw()

func on_player_landed() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	player.apply_horizontal_impulse(float(signi(direction)) * impulse_speed)
	_pulse = 1.0
	Feedback.play_sound("win")
	Feedback.vibrate(12)
	queue_redraw()

func _process(delta: float) -> void:
	_pulse = move_toward(_pulse, 0.0, delta * 5.0)
	queue_redraw()

func reset_attempt() -> void:
	_pulse = 0.0
	queue_redraw()

func _draw() -> void:
	var tint := Color("69c9ff").lerp(Color("dff8ff"), _pulse * 0.45)
	Design.box(Color("173d55"), tint, 6).draw(get_canvas_item(), Rect2(-50, -10, 100, 20))
	var arrow_direction := float(signi(direction))
	for offset in [-24.0, 0.0, 24.0]:
		var center := Vector2(offset, 0)
		draw_line(center + Vector2(-7 * arrow_direction, -5), center + Vector2(1 * arrow_direction, 0), tint, 2.2, true)
		draw_line(center + Vector2(1 * arrow_direction, 0), center + Vector2(-7 * arrow_direction, 5), tint, 2.2, true)
