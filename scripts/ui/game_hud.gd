class_name GameHUD
extends CanvasLayer

const Catalog := preload("res://scripts/systems/level_catalog.gd")

const Design := preload("res://scripts/ui/design.gd")

var controller: LevelController
var time_label: Label
var record_label: Label
var progress: ProgressBar
var result: Control
var pause_menu: Control
var result_time: Label
var result_best: Label
var result_medal: Label
var result_title: Label
var _flash: ColorRect

func _ready() -> void:
	layer = 5
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.theme = Design.theme()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var top := MarginContainer.new()
	root.add_child(top)
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 12
	top.offset_top = 12
	top.offset_right = -12
	var panel := PanelContainer.new()
	top.add_child(panel)
	var row := HBoxContainer.new()
	panel.add_child(row)
	var labels := VBoxContainer.new()
	labels.add_theme_constant_override("separation", 0)
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(labels)
	var mode_title := "INFINITO" if controller.level_config.level_number == 0 else "FASE %02d / %d" % [controller.level_config.level_number, Catalog.TOTAL_LEVELS]
	labels.add_child(Design.label(mode_title, 11, Design.MINT))
	time_label = Design.label("00:00.00", 23)
	labels.add_child(time_label)
	if controller.level_config.level_number == 0:
		record_label = Design.label("RECORDE 000 BLOCOS", 11, Design.MUTED)
		labels.add_child(record_label)
	row.add_child(_icon_button("↻", controller.restart_attempt))
	row.add_child(_icon_button("Ⅱ", controller.toggle_pause))
	progress = ProgressBar.new()
	root.add_child(progress)
	progress.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	progress.offset_left = 16
	progress.offset_right = -16
	progress.offset_top = 85
	progress.offset_bottom = 89
	progress.show_percentage = false
	progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress.add_theme_stylebox_override("background", Design.thin_bar(Color("1f3042")))
	progress.add_theme_stylebox_override("fill", Design.thin_bar(Design.MINT))
	var hint := Design.label("Toque e segure nos lados para mover  ·  ↻ reiniciar  ·  Ⅱ pausa", 11, Design.MUTED)
	root.add_child(hint)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -55
	hint.offset_bottom = -33
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result = _overlay(root)
	var result_column := _card(result)
	result_column.add_child(_center("↑", 42, Design.GOLD))
	result_title = _center("Fase concluída", 26)
	result_column.add_child(result_title)
	result_medal = _center("OURO", 15, Design.GOLD)
	result_column.add_child(result_medal)
	result_column.add_child(_center("SEU TEMPO", 11, Design.MUTED))
	result_time = _center("00:00.00", 38)
	result_column.add_child(result_time)
	result_best = _center("", 13, Design.MUTED)
	result_column.add_child(result_best)
	Design.spacer(result_column, 4)
	if controller.level_config.level_number == 0:
		result_column.add_child(Design.button("Tentar novamente", controller.restart_attempt, true))
		result_column.add_child(Design.button("Menu principal", func() -> void: Feedback.change_scene("res://scenes/ui/MainMenu.tscn")))
	else:
		result_column.add_child(Design.button("Próxima fase →" if controller.level_config.level_number < Catalog.TOTAL_LEVELS else "Ver minha jornada", controller.next_level, true))
		result_column.add_child(Design.button("Tentar novamente", controller.restart_attempt))
		result_column.add_child(Design.button("Seleção de fases", controller.go_to_levels))
	result.hide()
	pause_menu = _overlay(root)
	var pause_column := _card(pause_menu)
	pause_column.add_child(_center("Respire um pouco.", 25))
	pause_column.add_child(_center("Seu tempo está pausado.", 14, Design.MUTED))
	pause_column.add_child(Design.button("Continuar", controller.toggle_pause, true))
	pause_column.add_child(Design.button("Reiniciar fase", controller.restart_attempt))
	pause_column.add_child(Design.button("Configurações", Feedback.open_settings))
	pause_column.add_child(Design.button("Seleção de fases", controller.go_to_levels))
	pause_column.add_child(Design.button("Menu principal", func() -> void: Feedback.change_scene("res://scenes/ui/MainMenu.tscn")))
	pause_menu.hide()
	_flash = ColorRect.new()
	root.add_child(_flash)
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.color = Color(Design.CORAL, 0.0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _center(value: String, font_size: int, color: Color = Design.TEXT) -> Label:
	var node := Design.label(value, font_size, color)
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return node

func _icon_button(value: String, action: Callable) -> Button:
	var node := Button.new()
	node.text = value
	node.custom_minimum_size = Vector2(38, 38)
	node.add_theme_font_size_override("font_size", 22)
	node.add_theme_color_override("font_color", Design.MUTED)
	node.add_theme_color_override("font_hover_color", Design.MINT)
	node.add_theme_color_override("font_pressed_color", Design.MINT)
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := Design.box(Color.TRANSPARENT, Color.TRANSPARENT, 8)
		style.set_content_margin_all(0)
		if state == "hover":
			style.bg_color = Color("17273b")
		elif state == "pressed":
			style.bg_color = Color("20384e")
		node.add_theme_stylebox_override(state, style)
	node.pressed.connect(action)
	node.pressed.connect(func() -> void: Feedback.play_sound("tap"))
	return node

func _overlay(parent: Control) -> Control:
	var overlay := ColorRect.new()
	overlay.color = Color(0.02, 0.045, 0.08, 0.94)
	parent.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return overlay

func _card(parent: Control) -> VBoxContainer:
	var center := CenterContainer.new()
	parent.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 312
	center.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	return column

func show_result(elapsed: float, best: float, rank: int, record: bool) -> void:
	result_title.text = "Jornada concluída!" if controller.level_config.level_number == Catalog.TOTAL_LEVELS else "Fase %02d concluída" % controller.level_config.level_number
	result_medal.text = "MEDALHA DE " + SaveManager.get_medal_name(rank)
	var colors := [Design.TEXT, Color("e8aa7d"), Color("c9e0ee"), Design.GOLD]
	result_medal.add_theme_color_override("font_color", colors[rank])
	result_time.text = Design.time(elapsed)
	result_best.text = "Novo recorde pessoal!" if record else "Seu recorde: " + Design.time(best)
	result.show()
	result.modulate.a = 0
	create_tween().tween_property(result, "modulate:a", 1.0, 0.22)

func show_endless_result(blocks: int, best: int, record: bool) -> void:
	result_title.text = "NOVO RECORDE!" if record else "SUBIDA ENCERRADA"
	result_medal.text = "ALTURA ALCANÇADA"
	result_medal.add_theme_color_override("font_color", Design.GOLD if record else Design.MUTED)
	result_time.text = "%03d BLOCOS" % blocks
	result_best.text = "Recorde: %03d blocos" % best
	result.show()
	result.modulate.a = 0
	create_tween().tween_property(result, "modulate:a", 1.0, 0.22)

func flash_death() -> void:
	_flash.color.a = 0.13
	create_tween().tween_property(_flash, "color:a", 0.0, 0.22)
