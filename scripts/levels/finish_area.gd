class_name FinishArea
extends Area2D

signal player_reached(player: Player)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_reached.emit(body)
