class_name SpringPlatform
extends StaticBody2D

const PlatformArt := preload("res://scripts/visuals/platform_visual.gd")

# Impulso suficiente para atravessar cerca de tres intervalos normais.
@export var spring_force: float = 1080.0
var _pulse := 0.0

func _ready() -> void:
	add_to_group("attempt_resettable")
	PlatformArt.install(self)

func on_player_landed() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	player.apply_vertical_boost(spring_force)
	play_landing_visual()
	var feedback := get_node_or_null("/root/Feedback")
	if feedback != null:
		feedback.play_sound("win")
		feedback.vibrate(12)

func _process(delta: float) -> void:
	_pulse = move_toward(_pulse, 0.0, delta * 5.0)

func reset_attempt() -> void:
	_pulse = 0.0
	PlatformArt.refresh(self)

func play_landing_visual() -> void:
	_pulse = 1.0
	PlatformArt.refresh(self)

func get_visual_state() -> Dictionary:
	return {"kind": "spring", "pulse": _pulse}
