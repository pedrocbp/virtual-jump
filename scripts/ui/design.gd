class_name GameDesign
extends RefCounted

const Catalog := preload("res://scripts/systems/level_catalog.gd")

const INK := Color("0b1423")
const PANEL := Color("17273b")
const EDGE := Color("30465d")
const TEXT := Color("edf5fa")
const MUTED := Color("a0b5c9")
const MINT := Color("80efc0")
const GOLD := Color("ffd18a")
const CORAL := Color("ff7d87")
const CHAPTERS := Catalog.CHAPTERS

static func box(fill: Color, border: Color = EDGE, radius: int = 14) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

static func theme() -> Theme:
	var result := Theme.new()
	result.default_font_size = 15
	result.set_color("font_color", "Label", TEXT)
	result.set_color("font_color", "Button", TEXT)
	result.set_color("font_hover_color", "Button", TEXT)
	result.set_color("font_pressed_color", "Button", MINT)
	result.set_color("font_disabled_color", "Button", Color("758da5"))
	result.set_stylebox("normal", "Button", box(PANEL))
	result.set_stylebox("hover", "Button", box(Color("20384e"), MINT))
	result.set_stylebox("pressed", "Button", box(Color("102d32"), MINT))
	result.set_stylebox("disabled", "Button", box(Color("101d2e"), Color("243447")))
	var focus := box(Color.TRANSPARENT, MINT)
	focus.set_border_width_all(2)
	result.set_stylebox("focus", "Button", focus)
	result.set_stylebox("panel", "PanelContainer", box(PANEL))
	result.set_constant("separation", "VBoxContainer", 12)
	result.set_constant("separation", "HBoxContainer", 10)
	return result

static func thin_bar(fill: Color) -> StyleBoxFlat:
	var style := box(fill, fill, 2)
	style.set_content_margin_all(0)
	return style

static func label(value: String, font_size: int = 16, color: Color = TEXT) -> Label:
	var node := Label.new()
	node.text = value
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node

static func button(value: String, action: Callable, primary: bool = false) -> Button:
	var node := Button.new()
	node.text = value
	node.custom_minimum_size.y = 48
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if primary:
		node.add_theme_stylebox_override("normal", box(MINT, MINT))
		node.add_theme_stylebox_override("hover", box(Color("b2ffdb"), MINT))
		node.add_theme_stylebox_override("pressed", box(Color("59c99f"), MINT))
		for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			node.add_theme_color_override(state, INK)
	node.pressed.connect(action)
	node.pressed.connect(func() -> void: node.get_node("/root/Feedback").play_sound("tap"))
	return node

static func margin(parent: Node, padding: int = 24) -> MarginContainer:
	var node := MarginContainer.new()
	parent.add_child(node)
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		node.add_theme_constant_override("margin_" + side, padding)
	return node

static func spacer(parent: Node, height: float = 0.0, expand: bool = false) -> Control:
	var node := Control.new()
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.custom_minimum_size.y = height
	if expand:
		node.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(node)
	return node

static func time(seconds: float) -> String:
	var ticks := int(seconds * 100.0)
	return "%02d:%02d.%02d" % [floori(ticks / 6000.0), floori((ticks % 6000) / 100.0), ticks % 100]
