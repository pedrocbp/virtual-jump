class_name Hazard
extends Area2D

signal player_hit(player: Player)


func _ready() -> void:
	add_to_group("hazards")
	add_to_group("attempt_resettable")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_hit.emit(body)


func reset_attempt() -> void:
	pass
