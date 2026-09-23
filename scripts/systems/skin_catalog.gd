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
	var skin := get_skin(skin_id)
	var body: Color = skin["body"]
	var shade: Color = skin["shade"]
	var highlight: Color = skin["highlight"]
	var eye: Color = skin["eye"]
	var glow: Color = skin["glow"]
	var unit := radius / 16.0

	var glow_tint := glow
	glow_tint.a = 0.11
	target.draw_circle(center, radius + 5.0 * unit, glow_tint)
	target.draw_circle(center + Vector2(0, 2.0 * unit), radius, shade)
	target.draw_circle(center + Vector2(0, -1.0 * unit), radius - 1.0 * unit, body)
	target.draw_arc(center + Vector2(0, -1.0 * unit), radius - 2.0 * unit, PI, TAU, 24, highlight, 1.5 * unit, true)
	target.draw_circle(center + Vector2(-5.0, -6.0) * unit, 4.0 * unit, Color(highlight, 0.72))
	_draw_pattern(target, center, radius, String(skin["pattern"]), highlight, shade)
	target.draw_circle(center + Vector2(3.0 * facing, -1.0) * unit, 1.6 * unit, eye)
	target.draw_circle(center + Vector2(8.0 * facing, -1.0) * unit, 1.6 * unit, eye)

static func _draw_pattern(target: CanvasItem, center: Vector2, radius: float, pattern: String, accent: Color, shade: Color) -> void:
	var unit := radius / 16.0
	match pattern:
		"flame":
			target.draw_colored_polygon(PackedVector2Array([
				center + Vector2(-3, 8) * unit,
				center + Vector2(-5, 1) * unit,
				center + Vector2(0, -7) * unit,
				center + Vector2(2, 0) * unit,
				center + Vector2(6, -3) * unit,
				center + Vector2(5, 7) * unit,
			]), Color(accent, 0.52))
		"wave":
			for offset in [-2.0, 4.0]:
				target.draw_arc(center + Vector2(0, offset) * unit, 8.0 * unit, 0.15, PI - 0.15, 16, Color(accent, 0.62), 1.3 * unit, true)
		"star":
			var points := PackedVector2Array()
			for index in range(10):
				var angle := -PI * 0.5 + index * PI / 5.0
				var distance := (6.0 if index % 2 == 0 else 2.8) * unit
				points.append(center + Vector2.from_angle(angle) * distance)
			target.draw_colored_polygon(points, Color(accent, 0.72))
		"ring":
			target.draw_arc(center, 8.0 * unit, 0, TAU, 28, Color(accent, 0.65), 1.8 * unit, true)
			target.draw_circle(center, 2.2 * unit, Color(shade, 0.72))
		"crown":
			target.draw_colored_polygon(PackedVector2Array([
				center + Vector2(-7, 5) * unit,
				center + Vector2(-7, -2) * unit,
				center + Vector2(-3, 1) * unit,
				center + Vector2(0, -5) * unit,
				center + Vector2(3, 1) * unit,
				center + Vector2(7, -2) * unit,
				center + Vector2(7, 5) * unit,
			]), Color("ffd18a"))
