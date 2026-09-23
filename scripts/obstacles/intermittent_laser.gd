extends "res://scripts/obstacles/hazard.gd"

const HazardArt := preload("res://scripts/visuals/hazard_visual.gd")

@export var beam_length: float = 110.0
@export var inactive_duration: float = 2.0
@export var warning_duration: float = 0.6
@export var active_duration: float = 1.1
var state := "off"
var _elapsed := 0.0

func _ready() -> void:
	super._ready()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(beam_length, 8)
	$CollisionShape2D.shape = shape
	HazardArt.install(self)

func _physics_process(delta: float) -> void:
	_elapsed += delta
	var off := maxf(0.1, inactive_duration)
	var warning := maxf(0.2, warning_duration)
	var active := maxf(0.1, active_duration)
	var phase := fmod(_elapsed, off + warning + active)
	state = "off" if phase < off else ("warning" if phase < off + warning else "active")
	HazardArt.refresh(self)
	# Também detecta quem já estava no feixe quando ele liga.
	if state == "active":
		for body in get_overlapping_bodies():
			if body is Player:
				player_hit.emit(body)
				break

func _on_body_entered(body: Node2D) -> void:
	if state == "active" and body is Player:
		player_hit.emit(body)

func reset_attempt() -> void:
	_elapsed = 0
	state = "off"
	HazardArt.refresh(self)

func get_visual_state() -> Dictionary:
	var off := maxf(0.1, inactive_duration)
	var warning := maxf(0.2, warning_duration)
	var active := maxf(0.1, active_duration)
	var phase := fmod(_elapsed, off + warning + active)
	var progress := phase / off
	if state == "warning":
		progress = (phase - off) / warning
	elif state == "active":
		progress = (phase - off - warning) / active
	return {"kind": "laser", "state": state, "deadly": state == "active", "progress": clampf(progress, 0, 1)}
