extends Node2D

var tint := Color.WHITE
var strength := 1.0
var kind := "radial"
var age := 0.0
var duration := 0.46

func _process(delta: float) -> void:
	age += delta
	if age >= duration:
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	var progress := clampf(age / duration, 0.0, 1.0)
	if kind == "landing":
		_draw_landing(progress)
	else:
		_draw_radial(progress)

func _tint() -> Color:
	var style := preload("res://scripts/visuals/world_style.gd")
	return tint if style.theme_for(self) == 0 else style.color("highlight", style.theme_for(self))


func _draw_landing(progress: float) -> void:
	var fade := (1.0 - progress) * (1.0 - progress)
	var ring_color := Color(_tint(), fade * 0.45)
	draw_arc(Vector2.ZERO, 5.0 + progress * 23.0 * strength, PI + 0.15, TAU - 0.15, 28, ring_color, 1.6, true)
	for index in range(6):
		var spread := (float(index) / 5.0 - 0.5) * 2.0
		var speed := 34.0 + float((index * 17) % 19)
		var point := Vector2(spread * speed * progress * strength, -absf(spread) * 10.0 * progress - 5.0 * sin(progress * PI))
		point.y += progress * progress * 15.0
		draw_circle(point, maxf(0.7, fade * 2), Color(_tint(), fade * 0.65))


func _draw_radial(progress: float) -> void:
	var fade := (1.0 - progress) * (1.0 - progress)
	var color := Color(_tint(), fade * 0.78)
	draw_arc(Vector2.ZERO, 7.0 + progress * 31.0 * strength, 0, TAU, 36, color, 1.8, true)
	var count := 8
	for index in range(count):
		var direction := Vector2.from_angle(index * TAU / float(count) + 0.17)
		var variance := 0.78 + float((index * 13) % 7) * 0.05
		var point := direction * (7.0 + progress * 39.0 * strength * variance) + Vector2(0, progress * progress * 11.0)
		var particle_size := maxf(0.6, fade * (3.0 if kind == "death" else 2.5))
		draw_circle(point, particle_size, color)
		if kind == "death":
			draw_line(point - direction * 4.0 * fade, point + direction * 3.0 * fade, color, 1.2, true)
