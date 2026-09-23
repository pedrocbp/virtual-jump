class_name RetractableSpikes
extends Hazard

const Design := preload("res://scripts/ui/design.gd")

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
		queue_redraw()
		return
	state = next_state
	collision_shape.set_deferred("disabled", state != "active")
	queue_redraw()

func reset_attempt() -> void:
	_elapsed = maxf(0.0, start_offset)
	_refresh_state(true)

func _draw() -> void:
	var warning_alpha := 0.58 + sin(_elapsed * 18.0) * 0.25
	draw_rect(Rect2(-31, 9, 62, 7), Color("263949"))
	draw_line(Vector2(-28, 10), Vector2(28, 10), Design.CORAL if state == "active" else Color("5f7180"), 2.0, true)
	for index in range(4):
		var center_x := -22.5 + index * 15.0
		if state == "active":
			draw_colored_polygon(PackedVector2Array([
				Vector2(center_x - 7, 10), Vector2(center_x, -15), Vector2(center_x + 7, 10)
			]), Color("ff7d87"))
			draw_line(Vector2(center_x, -12), Vector2(center_x - 5, 8), Color("ffe0d1"), 1.2, true)
		elif state == "warning":
			draw_colored_polygon(PackedVector2Array([
				Vector2(center_x - 5, 10), Vector2(center_x, 3), Vector2(center_x + 5, 10)
			]), Color(Design.GOLD, warning_alpha))
		else:
			draw_circle(Vector2(center_x, 12), 1.5, Color("718392"))
