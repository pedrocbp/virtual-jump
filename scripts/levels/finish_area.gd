class_name FinishArea
extends Area2D

signal player_reached(player: Player)
var reached := false


func _ready() -> void:
	add_to_group("attempt_resettable")
	preload("res://scripts/effects/object_skin.gd").apply_to_tree(self)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		reached = true
		$Visual/Skin.queue_redraw()
		player_reached.emit(body)


func get_finish_visual_state() -> bool:
	return reached


func reset_attempt() -> void:
	reached = false
	$Visual/Skin.queue_redraw()
