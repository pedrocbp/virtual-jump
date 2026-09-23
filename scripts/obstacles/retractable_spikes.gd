class_name RetractableSpikes
extends Hazard

const HazardArt := preload("res://scripts/visuals/hazard_visual.gd")

@export var hidden_duration: float = 1.45
@export var warning_duration: float = 0.55
@export var active_duration: float = 1.05
@export var start_offset: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var state := "hidden"
var _elapsed := 0.0

func _ready() -> void:
	super._ready()
	_elapsed = maxf(0.0, start_offset)
	_refresh_state(true)
	HazardArt.install(self)

func _physics_process(delta: float) -> void:
	_elapsed += delta
	_refresh_state()

func _refresh_state(force: bool = false) -> void:
	var hidden := maxf(0.2, hidden_duration)
	var warning := maxf(0.2, warning_duration)
	var active := maxf(0.2, active_duration)
	var phase := fmod(_elapsed, hidden + warning + active)
	var next_state := "hidden" if phase < hidden else ("warning" if phase < hidden + warning else "active")
	if not force and next_state == state:
		HazardArt.refresh(self)
		return
	state = next_state
	collision_shape.set_deferred("disabled", state != "active")
	HazardArt.refresh(self)

func reset_attempt() -> void:
	_elapsed = maxf(0.0, start_offset)
	_refresh_state(true)

func get_visual_state() -> Dictionary:
	var hidden := maxf(0.2, hidden_duration)
	var warning := maxf(0.2, warning_duration)
	var active := maxf(0.2, active_duration)
	var phase := fmod(_elapsed, hidden + warning + active)
	var progress := phase / hidden
	if state == "warning":
		progress = (phase - hidden) / warning
	elif state == "active":
		progress = (phase - hidden - warning) / active
	return {"kind": "retractable", "state": state, "deadly": state == "active", "progress": clampf(progress, 0, 1)}
