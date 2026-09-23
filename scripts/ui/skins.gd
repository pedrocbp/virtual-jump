extends Control

const Design := preload("res://scripts/ui/design.gd")
const Backdrop := preload("res://scripts/ui/sky_backdrop.gd")
const Skins := preload("res://scripts/systems/skin_catalog.gd")
const Preview := preload("res://scripts/ui/skin_preview.gd")

var _buttons: Dictionary = {}
var _previews: Dictionary = {}

func _ready() -> void:
	theme = Design.theme()
	var sky := Backdrop.new()
	add_child(sky)
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	Design.margin(self, 18).add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	header.add_child(Design.button("← Menu", func() -> void: Feedback.change_scene("res://scenes/ui/MainMenu.tscn")))
	var title := Design.label("Skins", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(title)
	var unlocked := SaveManager.get_unlocked_skin_count()
	var summary := Design.label("%d / %d desbloqueadas  ·  apenas visual" % [unlocked, Skins.all().size()], 12, Design.MUTED)
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(summary)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)
	for skin_value in Skins.all():
		var skin: Dictionary = skin_value
		_add_skin_card(list, skin)
	_refresh()

func _add_skin_card(parent: VBoxContainer, skin: Dictionary) -> void:
	var skin_id := String(skin["id"])
	var card := PanelContainer.new()
	parent.add_child(card)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)
	var preview := Preview.new()
	row.add_child(preview)
	_previews[skin_id] = preview
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 2)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	info.add_child(Design.label(String(skin["name"]), 16, Design.TEXT))
	var description := Design.label(String(skin["description"]), 11, Design.MUTED)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(description)
	var requirement := Design.label(Skins.unlock_text(skin), 10, Design.GOLD)
	requirement.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(requirement)
	var select_button := Design.button("Usar", func() -> void: _select(skin_id))
	select_button.custom_minimum_size = Vector2(82, 46)
	select_button.add_theme_font_size_override("font_size", 12)
	info.add_child(select_button)
	_buttons[skin_id] = select_button

func _select(skin_id: String) -> void:
	if SaveManager.select_skin(skin_id):
		_refresh()

func _refresh() -> void:
	for skin_value in Skins.all():
		var skin: Dictionary = skin_value
		var skin_id := String(skin["id"])
		var unlocked := SaveManager.is_skin_unlocked(skin_id)
		var selected := SaveManager.selected_skin == skin_id
		var button := _buttons[skin_id] as Button
		button.disabled = not unlocked or selected
		button.text = "✓ Em uso" if selected else ("Usar" if unlocked else "Bloqueada")
		var preview: Node = _previews[skin_id]
		preview.call("configure", skin_id, selected, not unlocked)
