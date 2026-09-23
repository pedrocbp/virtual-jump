class_name SkinCatalog
extends RefCounted

const SKINS := [
	{
		"id": "classic", "name": "Clássica", "description": "A identidade original de VERTICAL.",
		"body": Color("80efc0"), "shade": Color("367e7a"), "highlight": Color("d9fff0"),
		"eye": Color("0b1423"), "glow": Color("80efc0"), "pattern": "none",
		"unlock_type": "free", "unlock_value": 0,
	},
	{
		"id": "ember", "name": "Brasa", "description": "Energia quente para continuar subindo.",
		"body": Color("ff8a62"), "shade": Color("9c3f4f"), "highlight": Color("ffe2ba"),
		"eye": Color("24131b"), "glow": Color("ff7d87"), "pattern": "flame",
		"unlock_type": "levels", "unlock_value": 5,
	},
	{
		"id": "ocean", "name": "Oceano", "description": "Azul profundo com ondas luminosas.",
		"body": Color("69c9ff"), "shade": Color("285a91"), "highlight": Color("ddf7ff"),
		"eye": Color("08182b"), "glow": Color("69c9ff"), "pattern": "wave",
		"unlock_type": "levels", "unlock_value": 15,
	},
	{
		"id": "champion", "name": "Campeã", "description": "Um brilho reservado a quem domina o tempo.",
		"body": Color("ffd166"), "shade": Color("a5652e"), "highlight": Color("fff4c2"),
		"eye": Color("251807"), "glow": Color("ffd18a"), "pattern": "star",
		"unlock_type": "golds", "unlock_value": 5,
	},
	{
		"id": "void", "name": "Vazio", "description": "Uma presença rara das maiores alturas.",
		"body": Color("9c7cff"), "shade": Color("392a70"), "highlight": Color("efe8ff"),
		"eye": Color("100b23"), "glow": Color("c5a1ff"), "pattern": "ring",
		"unlock_type": "endless", "unlock_value": 50,
	},
	{
		"id": "legend", "name": "Lenda", "description": "Símbolo de uma jornada completamente vencida.",
		"body": Color("f4f7fa"), "shade": Color("77889a"), "highlight": Color("ffffff"),
		"eye": Color("080b10"), "glow": Color("ffd18a"), "pattern": "crown",
		"unlock_type": "all_levels", "unlock_value": 70,
	},
]

static func all() -> Array:
	return SKINS

static func get_skin(skin_id: String) -> Dictionary:
	for skin in SKINS:
		if String(skin["id"]) == skin_id:
			return skin
	return SKINS[0]

static func has_skin(skin_id: String) -> bool:
	return String(get_skin(skin_id)["id"]) == skin_id

static func unlock_text(skin: Dictionary) -> String:
	match String(skin["unlock_type"]):
		"free":
			return "Disponível desde o início"
		"levels":
			return "Conclua %d fases" % int(skin["unlock_value"])
		"golds":
			return "Conquiste %d medalhas de ouro" % int(skin["unlock_value"])
		"endless":
			return "Alcance %d blocos no infinito" % int(skin["unlock_value"])
		"all_levels":
			return "Conclua todas as %d fases" % int(skin["unlock_value"])
	return "Bloqueada"

static func draw_ball(target: CanvasItem, center: Vector2, radius: float, skin_id: String, facing: float = 1.0) -> void:
	var style := preload("res://scripts/visuals/world_style.gd")
	var theme := style.theme_for(target)
	var skin := get_skin(skin_id)
	var body: Color = skin.body if theme == 0 else style.color("highlight", theme)
	var ink: Color = skin.eye if theme == 0 else style.color("ink", theme)
	var unit := radius / 16.0
	target.draw_circle(center, radius, body, true, -1, true)
	if theme == 0:
		target.draw_arc(center, radius - 1, 0.15, PI - 0.15, 28, skin.shade, 1.5 * unit, true)
		target.draw_arc(center, radius - 2.5 * unit, PI * 1.12, PI * 1.67, 20, skin.highlight, 1.2 * unit, true)
	# The face and badge occupy separate regions, even on a 32-unit player.
	_draw_badge(target, center + Vector2(-2 * facing, 7) * unit, unit, String(skin.pattern), ink)
	for offset in [-2.6, 2.6]:
		target.draw_circle(center + Vector2(5 * facing + offset, -3) * unit, 1.85 * unit, ink, true, -1, true)

static func _draw_badge(target: CanvasItem, center: Vector2, unit: float, pattern: String, ink: Color) -> void:
	match pattern:
		"flame":
			target.draw_colored_polygon(PackedVector2Array([center + Vector2(-4, 2) * unit, center + Vector2(-2, -2) * unit, center + Vector2(0, -5) * unit, center + Vector2(2, 0) * unit, center + Vector2(4, -2) * unit, center + Vector2(3, 3) * unit]), ink)
		"wave":
			for row in [-1, 2]:
				target.draw_polyline(PackedVector2Array([center + Vector2(-5, row) * unit, center + Vector2(-2, row - 1.5) * unit, center + Vector2(2, row + 1) * unit, center + Vector2(5, row - 1) * unit]), ink, unit, true)
		"star":
			var points := PackedVector2Array()
			for index in range(10):
				var angle := -PI * 0.5 + index * PI / 5.0
				points.append(center + Vector2.from_angle(angle) * (4.7 if index % 2 == 0 else 2.1) * unit)
			target.draw_colored_polygon(points, ink)
		"ring":
			target.draw_arc(center, 3.8 * unit, 0, TAU, 24, ink, 1.4 * unit, true)
		"crown":
			target.draw_colored_polygon(PackedVector2Array([center + Vector2(-5, 2) * unit, center + Vector2(-5, -3) * unit, center + Vector2(-2, -1) * unit, center + Vector2(0, -4) * unit, center + Vector2(2, -1) * unit, center + Vector2(5, -3) * unit, center + Vector2(5, 2) * unit]), ink)
