extends SceneTree

var levels := [41, 43, 45, 50]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE LEVELS 41-50: execute sem --headless.")
		quit()
		return
	var save := root.get_node_or_null("SaveManager")
	if save != null:
		save.set_script(load("res://tests/memory_save.gd"))
	root.size = Vector2i(360, 640)
	for number in levels:
		change_scene_to_file("res://scenes/levels/Level%02d.tscn" % number)
		for _frame in range(8):
			await process_frame
		await RenderingServer.frame_post_draw
		var path := OS.get_temp_dir().path_join("vertical-level-%02d.png" % number)
		root.get_texture().get_image().save_png(path)
		print("CAPTURE: ", path)
	quit()
