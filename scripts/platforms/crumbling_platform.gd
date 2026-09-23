class_name CrumblingPlatform
extends AnimatableBody2D

const PlatformArt := preload("res://scripts/visuals/platform_visual.gd")

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
	PlatformArt.install(self)

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
	PlatformArt.refresh(self)

func get_visual_state() -> Dictionary:
	return {"kind": "crumbling", "state": state, "hits": landing_count, "total": maxi(4, landings_before_fall)}
