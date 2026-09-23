extends CanvasLayer
## V5: native colors; no full-screen postprocessing or texture readback.
const Style := preload("res://scripts/visuals/world_style.gd")
const Design := preload("res://scripts/ui/design.gd")
signal theme_changed(index: int)
var _applied_theme := -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	SaveManager.settings_changed.connect(_apply_theme)
	_apply_theme()

func _apply_theme() -> void:
	var selected := get_selected_theme()
	if selected == _applied_theme:
		return
	_applied_theme = selected
	Style.active_theme = selected
	hide()
	RenderingServer.set_default_clear_color(Style.color("background", selected))
	Design.refresh_palette()
	_redraw_tree(get_tree().root)
	theme_changed.emit(selected)

func _redraw_tree(node: Node) -> void:
	if node is CanvasItem:
		node.queue_redraw()
	for child in node.get_children():
		_redraw_tree(child)

func get_selected_theme() -> int:
	return clampi(int(SaveManager.settings.get("visual_theme", 0)), 0, 2)
