extends SceneTree

const ICONS := {
	"res://assets/sprites/app_icon.svg": ["res://assets/sprites/app_icon_192.png", Vector2i(192, 192)],
	"res://assets/sprites/app_icon_foreground.svg": ["res://assets/sprites/app_icon_foreground_432.png", Vector2i(432, 432)],
	"res://assets/sprites/app_icon_background.svg": ["res://assets/sprites/app_icon_background_432.png", Vector2i(432, 432)],
	"res://assets/sprites/app_icon_monochrome.svg": ["res://assets/sprites/app_icon_monochrome_432.png", Vector2i(432, 432)],
}


func _initialize() -> void:
	for source: String in ICONS:
		var texture := load(source) as Texture2D
		if texture == null:
			push_error("Não foi possível carregar o ícone: " + source)
			quit(1)
			return
		var image := texture.get_image()
		var target: Array = ICONS[source]
		image.resize(target[1].x, target[1].y, Image.INTERPOLATE_LANCZOS)
		var error := image.save_png(target[0])
		if error != OK:
			push_error("Não foi possível gerar: " + target[0])
			quit(1)
			return
	print("Ícones Android gerados nas dimensões corretas.")
	quit()
