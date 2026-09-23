extends SceneTree

const LevelCatalog := preload("res://scripts/systems/level_catalog.gd")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _run() -> void:
	var save := root.get_node_or_null("SaveManager")
	if save == null:
		push_error("SaveManager ausente")
		quit(1)
		return
	save.set_script(load("res://tests/memory_save.gd"))
	var snapshot: Dictionary = save._serialize()
	var catalog = load("res://scripts/systems/skin_catalog.gd")
	_check(catalog.all().size() == 6, "Catálogo possui seis skins")

	save.completed_levels.clear()
	save.best_medals.clear()
	save.endless_best_blocks = 0
	save.selected_skin = "classic"
	_check(save.is_skin_unlocked("classic"), "Skin clássica começa desbloqueada")
	_check(not save.is_skin_unlocked("ember"), "Skin Brasa começa bloqueada")

	for level in range(1, 6):
		save.completed_levels.append(level)
	_check(save.is_skin_unlocked("ember"), "Cinco fases liberam Brasa")
	for level in range(6, 16):
		save.completed_levels.append(level)
	_check(save.is_skin_unlocked("ocean"), "Quinze fases liberam Oceano")
	for level in range(1, 6):
		save.best_medals[str(level)] = 3
	_check(save.is_skin_unlocked("champion"), "Cinco ouros liberam Campeã")
	save.endless_best_blocks = 50
	_check(save.is_skin_unlocked("void"), "Cinquenta blocos liberam Vazio")
	for level in range(16, LevelCatalog.TOTAL_LEVELS + 1):
		save.completed_levels.append(level)
	_check(save.is_skin_unlocked("legend"), "%d fases liberam Lenda" % LevelCatalog.TOTAL_LEVELS)

	var player_scene: PackedScene = load("res://scenes/player/Player.tscn")
	var player: CharacterBody2D = player_scene.instantiate()
	root.add_child(player)
	await process_frame
	for skin_value in catalog.all():
		var skin_id := String(skin_value["id"])
		_check(save.select_skin(skin_id), "Seleciona skin %s" % skin_id)
		await process_frame
		_check(String(player.get("_skin_id")) == skin_id, "Personagem aplica skin %s" % skin_id)

	player.queue_free()
	save._restore(snapshot)
	save.skin_changed.emit()
	print("SKIN SYSTEM: 6 skins, desbloqueios, seleção e personagem. Falhas: ", failures.size())
	quit(0 if failures.is_empty() else 1)
