extends Control

const Catalog := preload("res://scripts/systems/level_catalog.gd")
const Skins := preload("res://scripts/systems/skin_catalog.gd")
const Design := preload("res://scripts/ui/design.gd")
const Backdrop := preload("res://scripts/ui/sky_backdrop.gd")

func _ready() -> void:
	theme = Design.theme()
	var sky := Backdrop.new()
	add_child(sky)
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := VBoxContainer.new()
	Design.margin(self, 24).add_child(column)
	var top := HBoxContainer.new()
	column.add_child(top)
	top.add_child(Design.button("← Menu", func() -> void: Feedback.change_scene("res://scenes/ui/MainMenu.tscn")))
	var title := Design.label("Estatísticas", 25)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top.add_child(title)
	Design.spacer(column, 30)
	var card := PanelContainer.new()
	column.add_child(card)
	var stats := VBoxContainer.new()
	stats.add_theme_constant_override("separation", 14)
	card.add_child(stats)
	stats.add_child(Design.label("SEU PROGRESSO", 12, Design.MINT))
	stats.add_child(_stat("Fases concluídas", "%d / %d" % [SaveManager.completed_levels.size(), Catalog.TOTAL_LEVELS]))
	stats.add_child(_stat("Ouros", str(_medal_count(3))))
	stats.add_child(_stat("Pratas", str(_medal_count(2))))
	stats.add_child(_stat("Bronzes", str(_medal_count(1))))
	stats.add_child(_stat("Tentativas", str(SaveManager.total_attempts)))
	stats.add_child(_stat("Mortes", str(SaveManager.total_deaths)))
	stats.add_child(_stat("Skins", "%d / %d" % [SaveManager.get_unlocked_skin_count(), Skins.all().size()]))
	stats.add_child(Design.label("MODO INFINITO", 12, Design.MINT))
	stats.add_child(_stat("Maior altura", "%03d blocos" % SaveManager.get_endless_best_blocks()))
	Design.spacer(column, 12, true)
	column.add_child(Design.button("Voltar ao menu", func() -> void: Feedback.change_scene("res://scenes/ui/MainMenu.tscn"), true))

func _stat(label_text: String, value: String) -> Control:
	var row := HBoxContainer.new()
	var label := Design.label(label_text, 16, Design.TEXT)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	row.add_child(Design.label(value, 16, Design.GOLD))
	return row

func _medal_count(rank: int) -> int:
	var total := 0
	for value in SaveManager.best_medals.values():
		if int(value) == rank:
			total += 1
	return total
