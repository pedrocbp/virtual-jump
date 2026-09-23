class_name CrumblingPlatform
extends AnimatableBody2D

const Design := preload("res://scripts/ui/design.gd")

@export var landings_before_fall: int = 4
@export var fall_acceleration: float = 1050.0
@export var repair_delay: float = 3.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var state := "stable"
var landing_count := 0
var _origin := Vector2.ZERO
var _state_time := 0.0
var _fall_speed := 0.0
var _last_landing_frame := -1

func _ready() -> void:
	_origin = position
	# A posição passa a ser controlada por este script quando a plataforma
	# quebra; sem isso o AnimatableBody2D pode reaplicar a transformação antiga.
	sync_to_physics = false
	add_to_group("attempt_resettable")
	queue_redraw()

func on_player_landed() -> void:
	if state == "falling" or state == "gone":
		return
	# Em quinas, o move_and_slide pode relatar o mesmo corpo mais de uma vez.
	# Uma quicada física deve sempre valer exatamente um ponto de desgaste.
	var physics_frame := Engine.get_physics_frames()
	if physics_frame == _last_landing_frame:
		return
	_last_landing_frame = physics_frame
	landing_count += 1
	_state_time = 0.0
	if landing_count >= maxi(4, landings_before_fall):
		state = "falling"
		_fall_speed = 90.0
		# O último pouso ainda impulsiona a bolinha, mas a plataforma deixa de
		# ser sólida logo depois. Assim ela não consegue carregar o jogador
		# durante a queda e a quebra fica evidente.
		collision_shape.set_deferred("disabled", true)
		Feedback.play_sound("death")
		Feedback.vibrate(18)
	else:
		state = "cracking"
		Feedback.vibrate(8)
	queue_redraw()

func _physics_process(delta: float) -> void:
	if state == "cracking":
		_state_time += delta
		# Ela so cai se o jogador insistir em quicar nela. Se ele seguir
		# adiante, a plataforma se recupera depois de alguns segundos.
		if _state_time >= repair_delay:
			state = "stable"
			landing_count = 0
			_state_time = 0.0
	elif state == "falling":
		_state_time += delta
		_fall_speed += fall_acceleration * delta
		position.y += _fall_speed * delta
		rotation += delta * 1.8
		modulate.a = clampf(1.0 - _state_time * 0.55, 0.18, 1.0)
		if position.y > _origin.y + 480.0:
			state = "gone"
			visible = false
			collision_shape.set_deferred("disabled", true)
	queue_redraw()

func reset_attempt() -> void:
	state = "stable"
	landing_count = 0
	_state_time = 0.0
	_fall_speed = 0.0
	_last_landing_frame = -1
	sync_to_physics = false
	position = _origin
	rotation = 0.0
	visible = true
	modulate = Color.WHITE
	collision_shape.disabled = false
	collision_shape.set_deferred("disabled", false)
	reset_physics_interpolation()
	queue_redraw()

func _draw() -> void:
	var shake_x := sin(_state_time * 55.0) * 1.8 if state == "cracking" else 0.0
	draw_set_transform(Vector2(shake_x, 0.0))
	var fill := Color("573541") if state == "cracking" else Color("263c4b")
	var edge := Design.CORAL if state == "cracking" else Color("ffad83")
	var style := Design.box(fill, edge, 5)
	style.draw(get_canvas_item(), Rect2(-50, -10, 100, 20))
	draw_line(Vector2(-43, -7), Vector2(43, -7), Color(edge, 0.9), 2.0, true)
	# As rachaduras aumentam a cada pouso e avisam antes da quarta quicada.
	if landing_count > 0:
		draw_polyline(PackedVector2Array([
			Vector2(-23, -8), Vector2(-13, -1), Vector2(-18, 8)
		]), edge, 2.0, true)
		draw_polyline(PackedVector2Array([
			Vector2(8, -8), Vector2(1, 0), Vector2(15, 8)
		]), edge, 2.0, true)
		draw_line(Vector2(26, -6), Vector2(34, 6), edge, 2.0, true)
	if landing_count > 1:
		draw_polyline(PackedVector2Array([
			Vector2(-39, -7), Vector2(-31, 0), Vector2(-37, 7)
		]), edge, 2.0, true)
		draw_polyline(PackedVector2Array([
			Vector2(22, -8), Vector2(17, -1), Vector2(25, 7)
		]), edge, 2.0, true)
	if landing_count > 2:
		draw_line(Vector2(-5, -9), Vector2(-10, 0), edge, 2.4, true)
		draw_line(Vector2(-10, 0), Vector2(-3, 9), edge, 2.4, true)
