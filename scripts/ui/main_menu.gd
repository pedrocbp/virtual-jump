extends Control

const Catalog := preload("res://scripts/systems/level_catalog.gd")

const Design := preload("res://scripts/ui/design.gd")

const Backdrop := preload("res://scripts/ui/sky_backdrop.gd")

var _sky: Control
var _hero_space: Control
var _title: Label

func _ready() -> void:
	theme = Design.theme()
	_sky = Backdrop.new()
	_sky.name = "HeroBackdrop"
	_sky.hero = true
	add_child(_sky)
	_sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	Design.margin(self, 18).add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var brand := Design.label("↑  VERTICAL", 16, Design.MINT)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(brand)
	var settings := _icon_button("⚙", Feedback.open_settings)
	settings.name = "SettingsButton"
	settings.custom_minimum_size = Vector2(44, 44)
	settings.tooltip_text = "Configurações"
	settings.add_theme_font_size_override("font_size", 19)
	header.add_child(settings)
	_hero_space = Design.spacer(column, 150)
	_hero_space.name = "HeroClearSpace"
	_title = Design.label("Só mais um salto.", 28)
	_title.name = "HeroTitle"
	column.add_child(_title)
	var subtitle := Design.label("Encontre seu ritmo. Supere seu tempo.", 13, Design.MUTED)
	subtitle.name = "HeroSubtitle"
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(subtitle)
	Design.spacer(column, 8, true)
	var next := _next_level()
	var caption := "Jogar  ·  fase %02d" % next if next > 0 else "Revisitar as fases"
	column.add_child(_compact_button(caption, _play, true))
	var play_row := HBoxContainer.new()
	play_row.add_theme_constant_override("separation", 8)
	column.add_child(play_row)
	var levels_button := _compact_button("Fases", func() -> void: Feedback.change_scene("res://scenes/ui/LevelSelect.tscn"))
	levels_button.name = "LevelsButton"
	levels_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	play_row.add_child(levels_button)
	var endless_button := _compact_button("Infinito", _play_endless)
	endless_button.name = "EndlessButton"
	endless_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	play_row.add_child(endless_button)
	var utility_row := HBoxContainer.new()
	utility_row.add_theme_constant_override("separation", 8)
	column.add_child(utility_row)
	var skins_button := _compact_button("Skins", func() -> void: Feedback.change_scene("res://scenes/ui/Skins.tscn"))
	skins_button.name = "SkinsButton"
	skins_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	utility_row.add_child(skins_button)
	var stats_button := _compact_button("Estatísticas", _open_statistics)
	stats_button.name = "StatisticsButton"
	stats_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	utility_row.add_child(stats_button)
	var record := Design.label("Recorde infinito: %03d blocos" % SaveManager.get_endless_best_blocks(), 12, Design.GOLD)
	record.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(record)
	var completed := SaveManager.completed_levels.size()
	var progress_caption := Design.label("%02d / %d fases concluídas" % [completed, Catalog.TOTAL_LEVELS], 12, Design.MUTED)
	progress_caption.name = "ProgressCaption"
	progress_caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_caption.clip_text = false
	column.add_child(progress_caption)
	var progress := ProgressBar.new()
	progress.custom_minimum_size.y = 5
	progress.max_value = Catalog.TOTAL_LEVELS
	progress.value = completed
	progress.show_percentage = false
	progress.add_theme_stylebox_override("background", Design.thin_bar(Design.PANEL))
	progress.add_theme_stylebox_override("fill", Design.thin_bar(Design.MINT))
	column.add_child(progress)
	_layout_menu()
	resized.connect(_layout_menu)

func _layout_menu() -> void:
	if _sky == null or _hero_space == null:
		return
	var viewport_height := size.y
	_sky.hero_center_y = clampf(viewport_height * 0.20, 128.0, 160.0)
	_sky.queue_redraw()
	# O espaço termina depois do arco decorativo mais baixo. Assim o título
	# nunca é desenhado por cima da bolinha ou das plataformas do fundo.
	_hero_space.custom_minimum_size.y = clampf(viewport_height * 0.23, 147.0, 184.0)

func _compact_button(value: String, action: Callable, primary: bool = false) -> Button:
	var button := Design.button(value, action, primary)
	button.custom_minimum_size.y = 44 if not primary else 48
	button.add_theme_font_size_override("font_size", 13)
	if primary:
		return button
	var normal := Design.box(Color(Design.PANEL, 0.28), Color(Design.EDGE, 0.72), 10)
	var hover := Design.box(Color(Design.PANEL, 0.72), Color(Design.MINT, 0.75), 10)
	var pressed := Design.box(Color(Design.MINT, 0.12), Design.MINT, 10)
	for style in [normal, hover, pressed]:
		style.content_margin_top = 7
		style.content_margin_bottom = 7
		style.content_margin_left = 10
		style.content_margin_right = 10
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Design.MUTED)
	button.add_theme_color_override("font_hover_color", Design.TEXT)
	button.add_theme_color_override("font_pressed_color", Design.MINT)
	return button

func _icon_button(value: String, action: Callable) -> Button:
	var button := Design.button(value, action)
	button.custom_minimum_size = Vector2(44, 44)
	button.flat = true
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("hover", Design.box(Color(Design.PANEL, 0.46), Color.TRANSPARENT, 12))
	button.add_theme_stylebox_override("pressed", Design.box(Color(Design.MINT, 0.12), Color.TRANSPARENT, 12))
	button.add_theme_color_override("font_color", Design.MUTED)
	button.add_theme_color_override("font_hover_color", Design.TEXT)
	button.add_theme_color_override("font_pressed_color", Design.MINT)
	return button

func _next_level() -> int:
	for number in range(1, Catalog.TOTAL_LEVELS + 1):
		if SaveManager.is_level_unlocked(number) and not SaveManager.is_level_completed(number):
			return number
	return 0

func _play() -> void:
	var next := _next_level()
	var destination := "res://scenes/levels/Level%02d.tscn" % next if next > 0 else "res://scenes/ui/LevelSelect.tscn"
	_start_game(destination)

func _play_endless() -> void:
	_start_game("res://scenes/endless/Endless.tscn")

func _open_statistics() -> void:
	Feedback.change_scene("res://scenes/ui/Statistics.tscn")

func _start_game(destination: String) -> void:
	if not bool(SaveManager.settings.get("tutorial_seen", false)):
		SaveManager.tutorial_next_scene = destination
		Feedback.change_scene("res://scenes/tutorial/Tutorial.tscn")
	else:
		Feedback.change_scene(destination)
