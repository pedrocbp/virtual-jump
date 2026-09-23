class_name TemporaryHazard
extends Hazard

const HazardArt := preload("res://scripts/visuals/hazard_visual.gd")

@export var active_duration: float = 2.0
@export var inactive_duration: float = 1.5

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Polygon2D = $Visual

var _is_active := true
var _state_time := 0.0


func _ready() -> void:
	super._ready()
	HazardArt.install(self, true)


func _physics_process(delta: float) -> void:
	_state_time += delta
	if _is_active and _state_time >= active_duration:
		_set_active(false)
	elif not _is_active and _state_time >= inactive_duration:
		_set_active(true)


func _set_active(active: bool) -> void:
	_is_active = active
	_state_time = 0.0
	collision_shape.set_deferred("disabled", not active)
	visual.visible = active
	HazardArt.refresh(self)


func reset_attempt() -> void:
	_set_active(true)

func get_visual_state() -> Dictionary:
	if _is_active:
		return {"kind": "temporary_hazard", "state": "active", "deadly": true,
			"progress": clampf(_state_time / maxf(0.001, active_duration), 0, 1)}
	# Visual warning occupies the end of the existing inactive interval.
	# No new timer or alteration of the damage window.
	var warning := minf(0.45, maxf(0.001, inactive_duration) * 0.3)
	var remaining := inactive_duration - _state_time
	return {"kind": "temporary_hazard", "state": "warning" if remaining <= warning else "off", "deadly": false,
		"progress": clampf(1.0 - remaining / warning, 0, 1)}
