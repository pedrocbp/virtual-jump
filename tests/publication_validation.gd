extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	_check(ProjectSettings.get_setting("application/config/name") == "VERTICAL", "nome do app")
	_check(ProjectSettings.get_setting("application/config/version") == "1.0.0", "versão 1.0.0")
	_check(FileAccess.file_exists("res://assets/sprites/app_icon.svg"), "ícone do app")
	_check(FileAccess.file_exists("res://store/privacy_policy_pt_BR.md"), "política de privacidade")
	_check(FileAccess.file_exists("res://store/listing_pt_BR.md"), "ficha da loja")
	_check(FileAccess.file_exists("res://store/data_safety_pt_BR.md"), "declaração de dados")
	var presets := FileAccess.get_file_as_string("res://export_presets.cfg")
	_check(presets.contains("com.verticaljump.arcade"), "pacote Android")
	_check(presets.contains("name=\"Android AAB (Play Store)\""), "preset AAB")
	_check(presets.contains("gradle_build/target_sdk=\"36\""), "target API 36")
	_check(presets.contains("gradle_build/export_format=1"), "formato AAB")
	var save_source := FileAccess.get_file_as_string("res://scripts/systems/save_manager.gd")
	_check(not save_source.contains("DEVELOPMENT_MODE := true") and save_source.contains("OS.is_debug_build()"), "fases livres somente em builds de depuração")
	var scene_count := 0
	for path in DirAccess.get_files_at("res://scenes/levels"):
		if path.begins_with("Level") and path.ends_with(".tscn"):
			scene_count += 1
	_check(scene_count == 70, "70 fases")
	if failures.is_empty():
		print("PUBLICATION_VALIDATION: OK")
		quit()
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append("Falha: " + label)
