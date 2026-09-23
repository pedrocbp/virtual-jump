extends Node2D

const PlayerScene := preload("res://scenes/player/Player.tscn")
const PlatformScene := preload("res://scenes/platforms/NormalPlatform.tscn")
const GoalScene := preload("res://scenes/levels/FinishArea.tscn")
const Backdrop := preload("res://scripts/ui/sky_backdrop.gd")
const Design := preload("res://scripts/ui/design.gd")
const ObjectArt := preload("res://scripts/effects/object_skin.gd")

var player: Player
var left_seen := false
var right_seen := false
var instruction: Label
var left_hint: Label
var right_hint: Label
var completion_panel: VBoxContainer
var _ui_root: Control
var _header: MarginContainer

func _ready() -> void:
	var background := CanvasLayer.new()
	background.layer = -10
	add_child(background)
	var sky := Backdrop.new()
	background.add_child(sky)
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_add_floor()
	# Percurso introdutório: saltos curtos e progressivos, sem exigir
	# a precisão das fases normais. O terceiro salto é propositalmente
	# mais próximo para ensinar a troca de direção com segurança.
	for data in [Vector2(125, 515), Vector2(225, 435), Vector2(135, 355), Vector2(215, 275), Vector2(180, 190)]:
		var platform := PlatformScene.instantiate()
		platform.position = data
		add_child(platform)
	var goal := GoalScene.instantiate()
	goal.position = Vector2(180, 130)
	goal.player_reached.connect(_on_goal_reached)
	add_child(goal)
	player = PlayerScene.instantiate()
	player.position = Vector2(180, 560)
	add_child(player)
	var camera := Camera2D.new()
	camera.position = Vector2(180, 320)
	camera.enabled = true
	add_child(camera)
	ObjectArt.apply_to_tree(self)
	_build_ui()

func _add_floor() -> void:
	var floor := StaticBody2D.new()
	floor.position = Vector2(180, 620)
	add_child(floor)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(360, 20)
	collision.shape = shape
	floor.add_child(collision)
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([-180, -10, 180, -10, 180, 10, -180, 10])
	visual.color = Design.MINT
	floor.add_child(visual)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	_ui_root = Control.new()
	_ui_root.theme = Design.theme()
	_ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_ui_root)
	_ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_header = MarginContainer.new()
	_header.name = "TutorialHeader"
	_ui_root.add_child(_header)
	_header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	var top_labels := VBoxContainer.new()
	top_labels.add_theme_constant_override("separation", 2)
	_header.add_child(top_labels)
	var tutorial_title := Design.label("COMO JOGAR", 11, Design.MUTED)
	tutorial_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_labels.add_child(tutorial_title)
	instruction = Design.label("A bolinha pula sozinha.\nToque à esquerda ou à direita para direcioná-la.", 10, Design.TEXT)
	top_labels.add_child(instruction)
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_hint = Design.label("←", 30, Design.MINT)
	_ui_root.add_child(left_hint)
	left_hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	left_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	right_hint = Design.label("→", 30, Design.MINT)
	_ui_root.add_child(right_hint)
	right_hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	right_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_pulse_hint(left_hint, 0.0)
	_pulse_hint(right_hint, 0.35)
	completion_panel = VBoxContainer.new()
	_ui_root.add_child(completion_panel)
	completion_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	completion_panel.hide()
	completion_panel.add_child(Design.button("Começar a jogar", _finish, true))
	_layout_ui()
	_ui_root.resized.connect(_layout_ui)

func _layout_ui() -> void:
	if _ui_root == null or _header == null:
		return
	var viewport_size := _ui_root.size
	var side_margin := clampf(viewport_size.x * 0.055, 18.0, 30.0)
	var top_margin := clampf(viewport_size.y * 0.042, 24.0, 32.0)
	var bottom_margin := clampf(viewport_size.y * 0.03, 18.0, 28.0)
	var arrow_bottom := clampf(viewport_size.y * 0.08, 48.0, 72.0)

	_header.offset_left = side_margin
	_header.offset_top = top_margin
	_header.offset_right = -side_margin
	left_hint.offset_left = side_margin
	left_hint.offset_top = -(arrow_bottom + 52.0)
	left_hint.offset_right = side_margin + 44.0
	left_hint.offset_bottom = -arrow_bottom
	right_hint.offset_left = -(side_margin + 44.0)
	right_hint.offset_top = -(arrow_bottom + 52.0)
	right_hint.offset_right = -side_margin
	right_hint.offset_bottom = -arrow_bottom
	completion_panel.offset_left = maxf(42.0, side_margin + 20.0)
	completion_panel.offset_right = -maxf(42.0, side_margin + 20.0)
	completion_panel.offset_top = -(bottom_margin + 70.0)
	completion_panel.offset_bottom = -bottom_margin

func _pulse_hint(label: Label, delay: float) -> void:
	label.modulate.a = 0.55
	var tween := create_tween().set_loops()
	tween.tween_interval(delay)
	tween.tween_property(label, "modulate:a", 1.0, 0.45)
	tween.tween_property(label, "modulate:a", 0.55, 0.75)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if event.position.x < get_viewport_rect().size.x * 0.5:
			left_seen = true
		else:
			right_seen = true
		_update_instruction()

func _update_instruction() -> void:
	if left_seen and right_seen:
		instruction.text = "Perfeito! Agora você já sabe controlar a bolinha."
	elif left_seen:
		instruction.text = "Esquerda funcionando. Agora toque no lado direito."
	elif right_seen:
		instruction.text = "Direita funcionando. Agora toque no lado esquerdo."

func _on_goal_reached(_player: Player) -> void:
	instruction.text = "Chegada alcançada! Você já sabe jogar."
	left_hint.hide()
	right_hint.hide()
	completion_panel.show()

func _finish() -> void:
	SaveManager.set_setting("tutorial_seen", true)
	var destination := SaveManager.tutorial_next_scene
	SaveManager.tutorial_next_scene = ""
	if destination.is_empty():
		destination = "res://scenes/levels/Level01.tscn"
	Feedback.change_scene(destination)
