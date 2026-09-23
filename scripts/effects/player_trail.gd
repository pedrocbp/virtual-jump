extends Node2D

const LIFETIME := 0.24
const SAMPLE_INTERVAL := 0.035
const SPEED_THRESHOLD := 215.0

@export var target_path: NodePath = NodePath("..")

var _target: Player
var _samples: Array[Dictionary] = []
var _sample_clock := 0.0


func _ready() -> void:
	_target = get_node_or_null(target_path) as Player
	set_as_top_level(true)
	global_position = Vector2.ZERO
	z_as_relative = false
	z_index = -1


func _process(delta: float) -> void:
	for sample in _samples:
		sample["age"] = float(sample["age"]) + delta
	while not _samples.is_empty() and float(_samples[0]["age"]) >= LIFETIME:
		_samples.pop_front()

	if is_instance_valid(_target) and _target.visible and not _target.death_animating:
		var speed := _target.velocity.length()
		if speed >= SPEED_THRESHOLD:
			_sample_clock += delta
			if _sample_clock >= SAMPLE_INTERVAL:
				_sample_clock = fmod(_sample_clock, SAMPLE_INTERVAL)
				_samples.append({
					"position": _target.global_position,
					"age": 0.0,
					"speed": clampf(speed / 500.0, 0.45, 1.0),
				})
		else:
			_sample_clock = SAMPLE_INTERVAL
	queue_redraw()


func clear_trail() -> void:
	_samples.clear()
	_sample_clock = 0.0
	queue_redraw()


func _draw() -> void:
	for sample in _samples:
		var life: float = 1.0 - float(sample["age"]) / LIFETIME
		var trail_radius: float = 12.0 * life * float(sample["speed"])
		var color := _target.get_trail_color() if is_instance_valid(_target) else Color("80efc0")
		color.a = 0.13 * life * life
		draw_circle(Vector2(sample["position"]), trail_radius, color)
