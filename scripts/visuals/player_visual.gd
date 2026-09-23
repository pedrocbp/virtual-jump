extends Node2D
const Skins := preload("res://scripts/systems/skin_catalog.gd")
var source: Node2D

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(source):
		return
	var state: Dictionary = source.get_visual_state()
	var stretch := clampf(absf(state.velocity.y) / state.jump_force, 0, 1) * 0.11 * (1.0 - minf(state.squash, 1))
	var visual_scale := Vector2(1 + state.squash * 0.24 - stretch * 0.5, 1 - state.squash * 0.21 + stretch)
	var tilt := clampf(state.velocity.x / state.max_speed, -1, 1) * 0.045
	var opacity := 1.0
	if state.dying:
		var progress := clampf(state.death_age / 0.26, 0, 1)
		visual_scale *= (1 + sin(progress * PI) * 0.12) * lerpf(1, 0.18, progress * progress)
		tilt += progress * 0.38
		opacity = 1 - progress
	modulate.a = opacity
	draw_set_transform(Vector2.ZERO, tilt, visual_scale)
	Skins.draw_ball(self, Vector2.ZERO, state.radius, state.skin, state.facing)
