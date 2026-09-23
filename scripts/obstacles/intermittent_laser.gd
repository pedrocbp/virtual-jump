extends "res://scripts/obstacles/hazard.gd"

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

func _physics_process(delta: float) -> void:
	_elapsed += delta
	var off := maxf(0.1, inactive_duration)
	var warning := maxf(0.2, warning_duration)
	var active := maxf(0.1, active_duration)
	var phase := fmod(_elapsed, off + warning + active)
	state = "off" if phase < off else ("warning" if phase < off + warning else "active")
	queue_redraw()
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
	queue_redraw()

func _draw() -> void:
	var left := Vector2(-beam_length * 0.5, 0)
	var right := Vector2(beam_length * 0.5, 0)
	var tint := Color("ff7d87") if state == "active" else Color("ffd18a")
	if state == "active":
		draw_line(left, right, Color(1, 0.3, 0.4, 0.12), 14, true)
		draw_line(left, right, tint, 8, true)
		draw_line(left, right, Color("fff3e4"), 2, true)
	else:
		tint.a = (0.55 + 0.25 * sin(_elapsed * 20)) if state == "warning" else 0.15
		for index in range(int(beam_length / 12.0)):
			var point := left + Vector2(index * 12, 0)
			draw_line(point, point + Vector2(6, 0), tint, 2 if state == "warning" else 1, true)
	for point in [left, right]:
		draw_rect(Rect2(point - Vector2(4, 9), Vector2(8, 18)), Color("293c4f"))
		draw_circle(point, 3, Color(tint, 1.0))
