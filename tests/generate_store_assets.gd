extends SceneTree

func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://store"))
	var assets := {
		"res://assets/sprites/app_icon.svg": ["res://store/app_icon_512.png", Vector2i(512, 512)],
		"res://store/feature_graphic.svg": ["res://store/feature_graphic_1024x500.png", Vector2i(1024, 500)],
	}
	for source in assets:
		var image := Image.new()
		var svg_text := FileAccess.get_file_as_string(source)
		var load_error := image.load_svg_from_string(svg_text)
		if load_error != OK:
			push_error("Não foi possível carregar " + source)
			quit(1)
			return
		var expected_size: Vector2i = assets[source][1]
		if image.get_size() != expected_size:
			image.resize(expected_size.x, expected_size.y, Image.INTERPOLATE_LANCZOS)
		var destination: String = assets[source][0]
		var error := image.save_png(destination)
		if error != OK:
			push_error("Não foi possível salvar " + destination)
			quit(1)
			return
		print("Gerado: ", destination, " (", image.get_width(), "x", image.get_height(), ")")
	quit()
