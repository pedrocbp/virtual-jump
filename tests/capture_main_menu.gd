extends SceneTree

## Gera imagens da tela inicial nas proporções usadas pelo QA visual.

var sizes := [Vector2i(360, 640), Vector2i(360, 800), Vector2i(480, 720)]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE MAIN MENU: execute sem --headless para gerar as imagens.")
		quit()
		return
	var save := root.get_node_or_null("SaveManager")
	if save != null:
		save.set_script(load("res://tests/memory_save.gd"))
	for viewport_size in sizes:
		root.size = viewport_size
		change_scene_to_file("res://scenes/ui/MainMenu.tscn")
		for _frame in range(6):
			await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		var path := "res://build/main-menu-%dx%d.png" % [viewport_size.x, viewport_size.y]
		var result := image.save_png(path)
		if result != OK:
			push_error("Não foi possível salvar " + path)
	quit()
