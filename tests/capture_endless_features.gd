extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE ENDLESS FEATURES: execute sem --headless.")
		quit()
		return
	var save := root.get_node_or_null("SaveManager")
	if save != null:
		save.set_script(load("res://tests/memory_save.gd"))
	root.size = Vector2i(360, 640)
	change_scene_to_file("res://scenes/endless/Endless.tscn")
	for _frame in range(6):
		await process_frame
	var endless = current_scene
	endless._generate_until(-12000.0)
	await process_frame
	var vertical_current: Node2D
	var portal_entry: Node2D
	for generated: Node in endless._generated:
		var kind := String(generated.get_meta("endless_kind", ""))
		if kind == "vertical_current" and vertical_current == null:
			vertical_current = generated as Node2D
		elif kind == "portal_entry" and portal_entry == null:
			portal_entry = generated as Node2D
	var camera := endless.camera as Camera2D
	camera.set_process(false)
	camera.position_smoothing_enabled = false
	endless.player.set_physics_process(false)
	for capture_data in [["current", vertical_current], ["portal", portal_entry]]:
		var item: Node2D = capture_data[1]
		if item == null:
			continue
		camera.position = Vector2(180.0, item.position.y)
		camera.reset_smoothing()
		camera.force_update_scroll()
		for _frame in range(3):
			await process_frame
		await RenderingServer.frame_post_draw
		var path := OS.get_temp_dir().path_join("vertical-endless-%s.png" % String(capture_data[0]))
		root.get_texture().get_image().save_png(path)
		print("CAPTURE: ", path)
	quit()
