extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if change_scene_to_file("res://scenes/endless/Endless.tscn") != OK:
		_fail("Não foi possível abrir o infinito")
		return
	for _frame in range(5):
		await process_frame
	var endless := current_scene
	endless._generate_until(-12000.0)
	await process_frame
	var entry: GamePortal
	for generated: Node in endless._generated:
		if String(generated.get_meta("endless_kind", "")) == "portal_entry":
			entry = generated as GamePortal
			break
	if entry == null:
		_fail("Nenhum portal de entrada foi gerado")
		return
	entry.cycle_offset = 0.0
	entry.reset_attempt()
	if not entry.is_available() or not entry.monitoring:
		_fail("Portal não começa disponível")
		return
	entry._process(entry.visible_duration + 0.05)
	if entry.is_available() or entry.monitoring:
		_fail("Portal não desapareceu após a janela visível")
		return
	entry._process(entry.hidden_duration)
	if not entry.is_available() or not entry.monitoring:
		_fail("Portal não reapareceu após a espera")
		return
	print("INTERMITTENT PORTAL: OK (%.1fs visível / %.1fs oculto)" % [entry.visible_duration, entry.hidden_duration])
	quit()

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
