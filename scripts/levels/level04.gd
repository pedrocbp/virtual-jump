extends Node2D


func _ready() -> void:
	# A plataforma quebrável substitui a primeira plataforma fixa neste teste.
	var fixed_platform: StaticBody2D = $Main/PlatformOne
	fixed_platform.visible = false
	fixed_platform.collision_layer = 0
	fixed_platform.collision_mask = 0
