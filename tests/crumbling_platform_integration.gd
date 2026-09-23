extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var crumbling_scene: PackedScene = load("res://scenes/platforms/CrumblingPlatform.tscn")
	var platform: Node2D = crumbling_scene.instantiate()
	platform.position = Vector2(180, 420)
	world.add_child(platform)
	var player_scene: PackedScene = load("res://scenes/player/Player.tscn")
	var player: CharacterBody2D = player_scene.instantiate()
	player.position = Vector2(180, 370)
	player.velocity.y = 120.0
	world.add_child(player)

	var first_landing_seen := false
	var observed_landings := 0
	for _frame in range(180):
		await physics_frame
		var current_landings := int(platform.get("landing_count"))
		if current_landings > observed_landings:
			if current_landings != observed_landings + 1:
				push_error("Uma quicada foi contada mais de uma vez: %d -> %d" % [observed_landings, current_landings])
				quit(1)
				return
			observed_landings = current_landings
		if current_landings >= 1:
			first_landing_seen = true
		if current_landings < 4 and (platform.get("state") == "falling" or platform.get("state") == "gone"):
			push_error("A plataforma quebrou antes da quarta quicada")
			quit(1)
			return
		if platform.get("state") == "falling" or platform.get("state") == "gone":
			break

	if not first_landing_seen:
		push_error("A colisão real não registrou o primeiro pouso")
		quit(1)
		return
	if platform.get("state") != "falling" and platform.get("state") != "gone":
		push_error("A plataforma não caiu após os pousos repetidos: estado=%s pousos=%d" % [platform.get("state"), platform.get("landing_count")])
		quit(1)
		return
	if observed_landings != 4:
		push_error("A plataforma quebrou com %d quicadas, deveriam ser 4" % observed_landings)
		quit(1)
		return
	var fall_start_y := platform.position.y
	for _frame in range(8):
		await physics_frame
	var collision := platform.get_node("CollisionShape2D") as CollisionShape2D
	if not collision.disabled or platform.position.y <= fall_start_y:
		push_error("A quebra não removeu a colisão ou não deslocou a plataforma")
		quit(1)
		return

	print("CRUMBLING INTEGRATION: sequência 1-2-3-4 confirmada, colisão removida e plataforma em queda")
	quit(0)
