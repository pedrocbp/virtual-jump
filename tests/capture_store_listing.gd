extends SceneTree

const OUTPUT := "res://store/screenshots/"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Execute sem --headless para capturar a loja.")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var save := root.get_node_or_null("SaveManager")
	if save != null:
		save.set_script(load("res://tests/memory_save.gd"))
	root.size = Vector2i(360, 640)
	await _scene("res://scenes/ui/MainMenu.tscn", "01-menu.png")
	await _scene("res://scenes/levels/Level06.tscn", "02-fase-espinhos.png")
	await _scene("res://scenes/levels/Level32.tscn", "03-fase-laser.png")
	await _scene("res://scenes/levels/Level63.tscn", "04-fase-portal.png")
	await _capture_endless()
	await _scene("res://scenes/ui/Skins.tscn", "06-skins.png")
	quit()

func _scene(path: String, filename: String) -> void:
	change_scene_to_file(path)
	for _frame in range(10):
		await process_frame
	await RenderingServer.frame_post_draw
	_save(filename)

func _capture_endless() -> void:
	change_scene_to_file("res://scenes/endless/Endless.tscn")
	for _frame in range(10):
		await process_frame
	var endless := current_scene
	endless._generate_until(-12000.0)
	await process_frame
	var target: Node2D
	for generated: Node in endless._generated:
		if String(generated.get_meta("endless_kind", "")) == "vertical_current":
			target = generated as Node2D
			break
	if target != null:
		var camera := endless.camera as Camera2D
		camera.set_process(false)
		camera.position_smoothing_enabled = false
		endless.player.set_physics_process(false)
		camera.position = Vector2(180.0, target.position.y)
		camera.reset_smoothing()
		camera.force_update_scroll()
	for _frame in range(5):
		await process_frame
	await RenderingServer.frame_post_draw
	_save("05-modo-infinito.png")

func _save(filename: String) -> void:
	var image := root.get_texture().get_image()
	image.resize(1080, 1920, Image.INTERPOLATE_LANCZOS)
	var path := OUTPUT + filename
	var error := image.save_png(path)
	if error != OK:
		push_error("Falha ao salvar " + path)
	else:
		print("STORE_SCREENSHOT: ", path)

