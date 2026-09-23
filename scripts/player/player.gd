class_name Player
extends CharacterBody2D

const Skins := preload("res://scripts/systems/skin_catalog.gd")

signal landed(point: Vector2, impact_speed: float)

## Parâmetros centrais da movimentação para facilitar o balanceamento.
@export_category("Movimento")
@export var gravity: float = 1200.0
@export var jump_force: float = 500.0
@export var horizontal_acceleration: float = 1800.0
@export var max_horizontal_speed: float = 190.0
@export var horizontal_deceleration: float = 1400.0

@export_category("Visual")
@export var radius: float = 16.0
@export var ball_color: Color = Color("6ee7f7")

var _touches: Dictionary = {}
var controls_enabled := true
var _squash := 0.0
var _controlled_speed := 0.0
var _horizontal_impulse_speed := 0.0
var _vertical_boost_limit := 680.0
var _facing_direction := 1.0
var _skin_id := "classic"
var _death_age := 0.0
var death_animating := false

func _process(delta: float) -> void:
	_squash = maxf(0.0, _squash - delta * 7.0)
	if death_animating:
		_death_age += delta
		var progress := clampf(_death_age / 0.26, 0.0, 1.0)
		var pulse := sin(progress * PI)
		scale = Vector2.ONE * (1.0 + pulse * 0.18) * lerpf(1.0, 0.18, progress * progress)
		rotation = progress * 0.38
		modulate.a = 1.0 - progress
		if progress >= 1.0:
			visible = false
	queue_redraw()


func _ready() -> void:
	add_to_group("player")
	_apply_selected_skin()
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null and not save_manager.skin_changed.is_connected(_apply_selected_skin):
		save_manager.skin_changed.connect(_apply_selected_skin)
	queue_redraw()

func _apply_selected_skin() -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	var saved_skin := String(save_manager.get("selected_skin")) if save_manager != null else "classic"
	_skin_id = saved_skin if Skins.has_skin(saved_skin) else "classic"
	queue_redraw()

func get_trail_color() -> Color:
	return Skins.get_skin(_skin_id)["glow"]


func _input(event: InputEvent) -> void:
	if not controls_enabled:
		return
	if event is InputEventScreenTouch:
		if not event.pressed:
			_touches.erase(event.index)
	elif event is InputEventScreenDrag and _touches.has(event.index):
		_touches[event.index] = event.position


func _unhandled_input(event: InputEvent) -> void:
	if controls_enabled and event is InputEventScreenTouch and event.pressed:
		_touches[event.index] = event.position


func reset_motion() -> void:
	velocity = Vector2.ZERO
	_controlled_speed = 0
	_horizontal_impulse_speed = 0
	_vertical_boost_limit = 680.0
	_facing_direction = 1.0
	_touches.clear()
	_squash = 0.0
	_death_age = 0.0
	death_animating = false
	visible = true
	modulate = Color.WHITE
	scale = Vector2.ONE
	rotation = 0.0
	controls_enabled = true
	var trail := get_node_or_null("Trail")
	if trail != null:
		trail.clear_trail()


func play_death() -> void:
	release_controls()
	death_animating = true
	_death_age = 0.0
	visible = true
	modulate = Color.WHITE
	scale = Vector2.ONE
	rotation = 0.0

func release_controls() -> void:
	_touches.clear()
	controls_enabled = false

func apply_horizontal_impulse(speed: float) -> void:
	# A plataforma define o impulso inicial, mas o jogador ainda pode corrigir
	# a trajetória gradualmente durante o salto.
	_controlled_speed = 0.0
	_horizontal_impulse_speed = clampf(speed, -330.0, 330.0)
	if not is_zero_approx(_horizontal_impulse_speed):
		_facing_direction = signf(_horizontal_impulse_speed)

func apply_vertical_boost(force: float) -> void:
	# Preserva impulsos especiais, como a mola, sem permitir que correntes de ar
	# aumentem o limite vertical do salto normal.
	var clean_force := maxf(force, jump_force)
	velocity.y = -clean_force
	_vertical_boost_limit = maxf(680.0, clean_force)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		var vertical_push := 0.0
		for current in get_tree().get_nodes_in_group("vertical_currents"):
			vertical_push += float(current.push_at(global_position))
		velocity.y = clampf(velocity.y + vertical_push * delta, -_vertical_boost_limit, 850.0)
		if velocity.y >= -680.0:
			_vertical_boost_limit = 680.0

	var horizontal_input := _get_horizontal_input()
	if not is_zero_approx(horizontal_input):
		# O rosto responde à intenção do jogador imediatamente, mesmo antes
		# de a inércia horizontal terminar a troca de direção.
		_facing_direction = signf(horizontal_input)
		_controlled_speed = move_toward(
			_controlled_speed,
			horizontal_input * max_horizontal_speed,
			horizontal_acceleration * delta
		)
	else:
		_controlled_speed = move_toward(_controlled_speed, 0.0, horizontal_deceleration * delta)
	_horizontal_impulse_speed = move_toward(_horizontal_impulse_speed, 0.0, 430.0 * delta)
	var wind_push := 0.0
	for wind in get_tree().get_nodes_in_group("wind_fields"):
		wind_push += float(wind.push_at(global_position))
	velocity.x = clampf(_controlled_speed + _horizontal_impulse_speed + clampf(wind_push, -150, 150), -360.0, 360.0)

	var impact_speed := maxf(0.0, velocity.y)
	var was_falling := impact_speed > 0.0
	move_and_slide()
	if is_on_wall():
		_controlled_speed = 0

	# O salto só acontece depois do movimento e apenas ao aterrissar enquanto caía.
	if was_falling and is_on_floor():
		velocity.y = -jump_force
		_squash = clampf(impact_speed / jump_force, 0.72, 1.15)
		landed.emit(global_position + Vector2(0, radius), impact_speed)
		var notified_colliders: Dictionary = {}
		for index in range(get_slide_collision_count()):
			var collision := get_slide_collision(index)
			var collider := collision.get_collider()
			if collider == null:
				continue
			var collider_id := collider.get_instance_id()
			if collision.get_normal().y < -0.5 and not notified_colliders.has(collider_id) and collider.has_method("on_player_landed"):
				notified_colliders[collider_id] = true
				collider.on_player_landed()


func _get_horizontal_input() -> float:
	if not controls_enabled:
		return 0.0
	var keyboard_input := Input.get_axis("move_left", "move_right")
	if _touches.is_empty():
		return keyboard_input

	var screen_width := get_viewport_rect().size.x
	var left_touched := false
	var right_touched := false
	for touch_position in _touches.values():
		if touch_position.x < screen_width * 0.5:
			left_touched = true
		else:
			right_touched = true

	# Dois lados pressionados ao mesmo tempo se anulam.
	if left_touched == right_touched:
		return 0.0
	return -1.0 if left_touched else 1.0


func _draw() -> void:
	# Apenas o desenho é deformado; o corpo e a colisão continuam circulares.
	var stretch := clampf(absf(velocity.y) / jump_force, 0.0, 1.0) * 0.13 * (1.0 - minf(_squash, 1.0))
	var visual_scale := Vector2(
		1.0 + _squash * 0.28 - stretch * 0.55,
		1.0 - _squash * 0.24 + stretch
	)
	var tilt := clampf(velocity.x / max_horizontal_speed, -1.0, 1.0) * 0.045
	draw_set_transform(Vector2.ZERO, tilt, visual_scale)
	Skins.draw_ball(self, Vector2.ZERO, radius, _skin_id, _facing_direction)
