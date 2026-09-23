class_name BreakablePlatform
extends StaticBody2D

@export var break_delay: float = 0.55
@export var respawn_delay: float = 2.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Polygon2D = $Visual

var _state := "stable"
var _state_time := 0.0


func _ready() -> void:
	add_to_group("attempt_resettable")
	$Trigger.body_entered.connect(_on_trigger_body_entered)


func _physics_process(delta: float) -> void:
	if _state == "stable":
		return

	_state_time += delta
	if _state == "breaking":
		visual.modulate.a = max(0.2, 1.0 - _state_time / break_delay)
		if _state_time >= break_delay:
			_state = "broken"
			_state_time = 0.0
			collision_shape.set_deferred("disabled", true)
			visual.visible = false
	elif _state == "broken" and _state_time >= respawn_delay:
		_state = "stable"
		_state_time = 0.0
		collision_shape.set_deferred("disabled", false)
		visual.modulate.a = 1.0
		visual.visible = true


func _on_trigger_body_entered(body: Node2D) -> void:
	if body is Player and _state == "stable":
		_state = "breaking"
		_state_time = 0.0


func reset_attempt() -> void:
	_state = "stable"
	_state_time = 0.0
	collision_shape.set_deferred("disabled", false)
	visual.modulate.a = 1.0
	visual.visible = true
