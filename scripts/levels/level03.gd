extends Node2D


func _ready() -> void:
	# Na Level03, a plataforma móvel substitui a quinta plataforma fixa.
	var fixed_platform: StaticBody2D = $Main/PlatformFive
	fixed_platform.visible = false
	fixed_platform.collision_layer = 0
	fixed_platform.collision_mask = 0
