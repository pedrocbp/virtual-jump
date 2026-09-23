extends RefCounted
## Native palettes shared by gameplay and development previews.
static var active_theme := 0
const OUTLINE := 1.5
const CORNER := 4
const ORIGINAL := {
	"background": Color("0b1423"), "surface": Color("17273b"),
	"support": Color("80efc0"), "danger": Color("ff7d87"),
	"flow": Color("69c9ff"), "portal": Color("b59aff"),
	"fragile": Color("ffad83"), "spring": Color("ffd18a"),
	"warning": Color("ffd18a"),
	"ink": Color("0b1423"), "highlight": Color("edf5fa"),
}

static func theme_for(node: Node) -> int:
	var ancestor := node
	while ancestor != null:
		if ancestor.has_meta("visual_preview_theme"):
			return clampi(int(ancestor.get_meta("visual_preview_theme")), 0, 2)
		ancestor = ancestor.get_parent()
	return active_theme

static func color(role: String, theme: int) -> Color:
	if theme == 0:
		return ORIGINAL.get(role, ORIGINAL.highlight)
	var negative := role in ["background", "surface", "ink"]
	return Color.BLACK if negative == (theme == 1) else Color.WHITE

static func plate_style(theme: int, role := "support") -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color(role, theme)
	style.set_corner_radius_all(CORNER)
	style.anti_aliasing = true
	if theme == 0:
		style.shadow_color = Color(0.01, 0.025, 0.045, 0.24)
		style.shadow_offset = Vector2(0, 2)
		style.shadow_size = 1
	return style
