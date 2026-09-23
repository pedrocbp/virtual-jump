class_name GameDesign
extends RefCounted

const Catalog := preload("res://scripts/systems/level_catalog.gd")
const Palette := preload("res://scripts/visuals/world_style.gd")
static var _palette_items: Array[WeakRef] = []
static var _slider_handles: Dictionary = {}

const INK := Color("0b1423")
const PANEL := Color("17273b")
const EDGE := Color("30465d")
const TEXT := Color("edf5fa")
const MUTED := Color("a0b5c9")
const MINT := Color("80efc0")
const GOLD := Color("ffd18a")
const CORAL := Color("ff7d87")
const CHAPTERS := Catalog.CHAPTERS

static func box(fill: Color, border: Color = EDGE, radius: int = 10) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.set_meta("palette_fill", fill)
	style.set_meta("palette_border", border)
	_track_palette(style)
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
	_track_palette(result)
	return result

static func thin_bar(fill: Color) -> StyleBoxFlat:
	var style := box(fill, fill, 2)
	style.set_content_margin_all(0)
	return style

static func label(value: String, font_size: int = 16, color: Color = TEXT) -> Label:
	var node := Label.new()
	node.text = value
	node.add_theme_font_size_override("font_size", font_size)
	font_color(node, "font_color", color)
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
			font_color(node, state, INK)
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

static func native_color(source: Color, background := false) -> Color:
	if Palette.active_theme == 0:
		return source
	var result := Palette.color("background" if background else "highlight", Palette.active_theme)
	result.a = source.a
	return result

static func font_color(node: Control, key: String, source: Color) -> void:
	var colors: Dictionary = node.get_meta("palette_fonts", {})
	colors[key] = source
	node.set_meta("palette_fonts", colors)
	_track_palette(node)

static func paint(node: ColorRect, source: Color) -> void:
	node.set_meta("palette_background", source)
	_track_palette(node)

static func _track_palette(item: Object) -> void:
	if not item.has_meta("palette_registered"):
		item.set_meta("palette_registered", true)
		_palette_items.append(weakref(item))
		if _palette_items.size() % 128 == 0:
			_palette_items = _palette_items.filter(func(ref: WeakRef) -> bool: return ref.get_ref() != null)
	_apply_palette(item)

static func refresh_palette() -> void:
	_palette_items = _palette_items.filter(func(ref: WeakRef) -> bool: return ref.get_ref() != null)
	for reference in _palette_items:
		_apply_palette(reference.get_ref())

static func _apply_palette(item: Object) -> void:
	if item is StyleBoxFlat:
		var fill: Color = item.get_meta("palette_fill")
		# Solid primary actions invert the text; surfaces remain negative space.
		var primary := Color(fill, 1) in [MINT, Color("b2ffdb"), Color("59c99f")]
		item.bg_color = native_color(fill, not primary)
		item.border_color = native_color(item.get_meta("palette_border"))
	elif item is Theme:
		item.set_color("font_color", "Label", native_color(TEXT))
		for key in ["font_color", "font_hover_color", "font_focus_color"]:
			item.set_color(key, "Button", native_color(TEXT))
		item.set_color("font_pressed_color", "Button", native_color(MINT))
		item.set_color("font_disabled_color", "Button", native_color(Color("758da5")))
		if not _slider_handles.has(Palette.active_theme):
			var bitmap := Image.new()
			var tint := native_color(MINT).to_html(false)
			bitmap.load_svg_from_string('<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"><circle cx="8" cy="8" r="6" fill="#%s"/></svg>' % tint)
			_slider_handles[Palette.active_theme] = ImageTexture.create_from_image(bitmap)
		for key in ["grabber", "grabber_highlight", "grabber_disabled"]:
			item.set_icon(key, "HSlider", _slider_handles[Palette.active_theme])
	elif item is Control:
		if item.has_meta("palette_fonts"):
			var colors: Dictionary = item.get_meta("palette_fonts")
			for key in colors:
				item.add_theme_color_override(key, native_color(colors[key], colors[key] == INK))
		if item is ColorRect and item.has_meta("palette_background"):
			item.color = native_color(item.get_meta("palette_background"), true)

static func icon_button(kind: String, action: Callable) -> Button:
	var node := preload("res://scripts/ui/action_icon.gd").new()
	node.icon_kind = kind
	node.custom_minimum_size = Vector2(44, 44)
	node.tooltip_text = {"pause": "Pausar", "restart": "Reiniciar", "settings": "Configurações"}.get(kind, "")
	node.pressed.connect(action)
	node.pressed.connect(func() -> void: node.get_node("/root/Feedback").play_sound("tap"))
	return node
