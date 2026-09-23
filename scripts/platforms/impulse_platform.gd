class_name ImpulsePlatform
extends StaticBody2D

const PlatformArt := preload("res://scripts/visuals/platform_visual.gd")

@export_range(-1, 1, 2) var direction: int = 1
@export_range(220.0, 330.0, 5.0) var impulse_speed: float = 300.0

var _pulse := 0.0
var _visual_time := 0.0

func _ready() -> void:
	add_to_group("attempt_resettable")
	PlatformArt.install(self)

func on_player_landed() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	player.apply_horizontal_impulse(float(signi(direction)) * impulse_speed)
	play_landing_visual()
	Feedback.play_sound("win")
	Feedback.vibrate(12)

func _process(delta: float) -> void:
	_visual_time += delta
	_pulse = move_toward(_pulse, 0.0, delta * 5.0)

func reset_attempt() -> void:
	_pulse = 0.0
	_visual_time = 0.0
	PlatformArt.refresh(self)

func play_landing_visual() -> void:
	_pulse = 1.0
	PlatformArt.refresh(self)

func get_visual_state() -> Dictionary:
	return {"kind": "impulse", "direction": signi(direction), "phase": _visual_time, "pulse": _pulse}
