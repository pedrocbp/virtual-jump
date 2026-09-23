class_name LevelLayout
extends Node2D

## Define o percurso de uma fase sem duplicar a cena principal e sua logica.
@export var platform_positions: PackedVector2Array = PackedVector2Array()
@export var disabled_platform_indices: PackedInt32Array = PackedInt32Array()
@export var goal_position: Vector2 = Vector2(250.0, -350.0)

const PLATFORM_NAMES: Array[StringName] = [
	&"PlatformOne",
	&"PlatformTwo",
	&"PlatformThree",
	&"PlatformFour",
	&"PlatformFive",
	&"PlatformSix",
	&"PlatformSeven",
	&"PlatformEight",
	&"PlatformNine",
	&"PlatformTen",
]

@onready var main: LevelController = $Main


func _ready() -> void:
	_apply_platform_positions()
	_disable_replaced_platforms()
	var goal := main.get_node_or_null("Goal") as Area2D
	if goal != null:
		goal.position = goal_position


func _apply_platform_positions() -> void:
	var position_count := mini(platform_positions.size(), PLATFORM_NAMES.size())
	for index in range(position_count):
		var platform := main.get_node_or_null(str(PLATFORM_NAMES[index])) as Node2D
		if platform != null:
			platform.position = platform_positions[index]


func _disable_replaced_platforms() -> void:
	for index in disabled_platform_indices:
		if index < 0 or index >= PLATFORM_NAMES.size():
			continue

		var platform := main.get_node_or_null(str(PLATFORM_NAMES[index])) as StaticBody2D
		if platform == null:
			continue

		platform.visible = false
		platform.collision_layer = 0
		platform.collision_mask = 0
