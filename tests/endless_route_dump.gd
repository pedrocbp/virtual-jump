extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	change_scene_to_file("res://scenes/endless/Endless.tscn")
	for _frame in range(5):
		await process_frame
	var endless := current_scene
	endless._generate_until(-7000.0)
	await process_frame
	var platforms: Array[Node] = []
	for generated: Node in endless._generated:
		if generated.has_meta("endless_index"):
			platforms.append(generated)
	platforms.sort_custom(func(a: Node, b: Node) -> bool: return int(a.get_meta("endless_index")) < int(b.get_meta("endless_index")))
	for platform: Node in platforms:
		var script := platform.get_script() as Script
		var kind := script.resource_path.get_file().trim_suffix(".gd") if script != null else "normal"
		print("ROUTE index=%d height=%d kind=%s x=%.0f y=%.0f gap=%.0f spring_landing=%s valid=%s" % [
			int(platform.get_meta("endless_index")), int(platform.get_meta("height_blocks")), kind,
			platform.position.x, platform.position.y, float(platform.get_meta("vertical_gap")),
			str(platform.get_meta("spring_landing")), str(platform.get_meta("layout_valid"))])
	quit()
