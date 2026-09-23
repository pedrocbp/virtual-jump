extends Control

const Catalog := preload("res://scripts/systems/level_catalog.gd")

const Design := preload("res://scripts/ui/design.gd")

const Backdrop := preload("res://scripts/ui/sky_backdrop.gd")

func _ready() -> void:
	theme = Design.theme()
	var sky := Backdrop.new()
	add_child(sky)
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := VBoxContainer.new()
	Design.margin(self, 20).add_child(column)
	var top := HBoxContainer.new()
	column.add_child(top)
	top.add_child(Design.button("← Menu", func() -> void: Feedback.change_scene("res://scenes/ui/MainMenu.tscn")))
	var title := Design.label("Sua jornada", 23)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top.add_child(title)
	column.add_child(Design.label("%d de %d fases concluídas" % [SaveManager.completed_levels.size(), Catalog.TOTAL_LEVELS], 14, Design.MUTED))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var chapters := VBoxContainer.new()
	chapters.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chapters.add_theme_constant_override("separation", 16)
	scroll.add_child(chapters)
	for chapter in range(Catalog.CHAPTERS.size()):
		chapters.add_child(Design.label("%02d  /  %s" % [chapter + 1, Design.CHAPTERS[chapter]], 16, Design.MINT))
		var grid := GridContainer.new()
		grid.columns = 2
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 10)
		chapters.add_child(grid)
		for offset in range(5):
			var number := chapter * 5 + offset + 1
			var unlocked := SaveManager.is_level_unlocked(number)
			var best := SaveManager.get_best_time(number)
			var caption := "FASE %02d\n" % number
			if not unlocked:
				caption += "Bloqueada\nConclua a anterior"
			elif best < 0:
				caption += "Novo percurso\nVamos subir ↑"
			else:
				caption += "%s\n%s" % [SaveManager.get_medal_name(SaveManager.get_best_medal(number)), Design.time(best)]
			var target := number
			var button := Design.button(caption, func() -> void: Feedback.change_scene("res://scenes/levels/Level%02d.tscn" % target))
			button.custom_minimum_size = Vector2(140, 98)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.add_theme_font_size_override("font_size", 13)
			button.disabled = not unlocked
			if best >= 0:
				Design.font_color(button, "font_color", Design.GOLD)
			grid.add_child(button)
	column.add_child(Design.label("Conclua uma fase para liberar a próxima.", 12, Design.MUTED))
