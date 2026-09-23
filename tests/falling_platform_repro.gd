extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	change_scene_to_file("res://scenes/levels/Level33.tscn")
	for frame in range(5):
		await process_frame
	var main = current_scene.get_node("Main")
	var platform = current_scene.get_node("FallingPlatform1")
	platform.on_player_landed()
	for frame in range(100):
		await physics_frame
	main.restart_attempt()
	await process_frame
	print("RESET_VALUES visible=", platform.visible, " position=", platform.position, " origin=", platform._origin, " state=", platform.state, " disabled=", platform.get_node("CollisionShape2D").disabled)
	assert(platform.visible)
	assert(platform.position.is_equal_approx(platform._origin))
	assert(platform.state == "stable")
	assert(not platform.get_node("CollisionShape2D").disabled)
	print("FALLING_PLATFORM_RESET_OK")
	quit()
