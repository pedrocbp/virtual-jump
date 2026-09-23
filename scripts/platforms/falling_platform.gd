extends AnimatableBody2D

const Design := preload("res://scripts/ui/design.gd")
@export var fall_delay: float = 0.4
@export var fall_acceleration: float = 950.0
var state := "stable"
var _origin: Vector2
var _elapsed := 0.0
var _fall_speed := 0.0
var _style: StyleBoxFlat

func _ready() -> void:
	_origin = position
	add_to_group("attempt_resettable")
	_style = Design.box(Color("403329"), Color("ffc185"), 5)
	set_process(true)
	show()
	queue_redraw()

func on_player_landed() -> void:
	if state == "stable":
		state = "shaking"
		_elapsed = 0

func _physics_process(delta: float) -> void:
	if state == "shaking":
		_elapsed += delta
		if _elapsed >= maxf(0.1, fall_delay):
			state = "falling"
	elif state == "falling":
		_fall_speed += fall_acceleration * delta
		position.y += _fall_speed * delta
		if position.y > _origin.y + 500:
			state = "gone"
			visible = false
			$CollisionShape2D.set_deferred("disabled", true)
	queue_redraw()

func reset_attempt() -> void:
	state = "stable"
	_elapsed = 0
	_fall_speed = 0
	# Restaurar todos os estados visuais evita que o hide() do estado gone sobreviva ao reset.
	visible = true
	modulate = Color.WHITE
	scale = Vector2.ONE
	rotation = 0.0
	# A plataforma é animada pelo script; o servidor físico não deve reaplicar
	# a transformação antiga depois de uma queda.
	sync_to_physics = false
	position = _origin
	reset_physics_interpolation()
	$CollisionShape2D.disabled = false
	$CollisionShape2D.set_deferred("disabled", false)
	queue_redraw()
	call_deferred("_finish_reset")

func _finish_reset() -> void:
	if not is_inside_tree():
		return
	visible = true
	sync_to_physics = false
	position = _origin
	$CollisionShape2D.disabled = false
	queue_redraw()

func _draw() -> void:
	if _style == null:
		return
	if state == "shaking":
		draw_set_transform(Vector2(sin(_elapsed * 65) * 1.5, 0))
	_style.draw(get_canvas_item(), Rect2(-50, -10, 100, 20))
	for x in [-24, 0, 24]:
		draw_polyline(PackedVector2Array([Vector2(x - 4, -2), Vector2(x, 3), Vector2(x + 4, -2)]), Color("ffc185"), 1.5, true)
