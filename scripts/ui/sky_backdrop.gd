extends Control

const Design := preload("res://scripts/ui/design.gd")
const Style := preload("res://scripts/visuals/world_style.gd")
const Skins := preload("res://scripts/systems/skin_catalog.gd")

var hero := false
var hero_center_y := 206.0
var _time := 0.0

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	set_process(hero)

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var theme := Style.theme_for(self)
	draw_rect(Rect2(Vector2.ZERO, size), Style.color("background", theme))
	if theme == 0:
		for row in range(16):
			var shade := Color("102034").lerp(Design.INK, float(row) / 16.0)
			draw_rect(Rect2(0, row * size.y / 16.0, size.x, size.y / 16.0 + 1), shade)
		for i in range(16):
			var point := Vector2(fmod(i * 97.0 + 23.0, maxf(1, size.x)), fmod(i * 131.0 + 51.0, maxf(1, size.y)))
			draw_circle(point, 1, Color(0.6, 0.8, 0.95, 0.08))
	if not hero:
		return
	var center := Vector2(size.x * 0.5, hero_center_y)
	if theme == 0:
		draw_arc(center, 85, -2.8, -0.35, 48, Color("24354a"), 1.0, true)
	for i in range(3):
		var origin := center + Vector2(-84 + i * 54, 55 - i * 32)
		draw_style_box(_hero_plate(theme), Rect2(origin, Vector2(60, 12)))
	var bob := sin(_time * 1.7) * 5.0
	var save := get_node_or_null("/root/SaveManager")
	Skins.draw_ball(self, center + Vector2(8, -17 + bob), 20, save.selected_skin if save != null else "classic")

var _hero_styles: Dictionary = {}
func _hero_plate(theme: int) -> StyleBoxFlat:
	if not _hero_styles.has(theme):
		_hero_styles[theme] = Style.plate_style(theme)
	return _hero_styles[theme]
