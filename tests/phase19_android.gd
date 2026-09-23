extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _run() -> void:
	var project := ConfigFile.new()
	check(project.load("res://project.godot") == OK, "Abrir project.godot")
	check(project.get_value("application", "config/name") == "VERTICAL", "Nome definitivo")
	check(project.get_value("application", "config/version") == "1.0.0", "Versão do projeto")
	check(int(project.get_value("display", "window/handheld/orientation")) == 1, "Orientação retrato")
	check(project.get_value("rendering", "renderer/rendering_method.mobile") == "gl_compatibility", "Renderizador mobile")

	var presets := ConfigFile.new()
	check(presets.load("res://export_presets.cfg") == OK, "Abrir presets Android")
	for section in ["preset.0.options", "preset.1.options"]:
		check(presets.get_value(section, "package/unique_name") == "com.verticaljump.arcade", "Pacote em " + section)
		check(presets.get_value(section, "package/name") == "VERTICAL", "Nome Android em " + section)
		check(int(presets.get_value(section, "version/code")) == 1, "Version code em " + section)
		check(presets.get_value(section, "version/name") == "1.0.0", "Version name em " + section)
		check(bool(presets.get_value(section, "architectures/arm64-v8a")), "Arquitetura arm64 em " + section)
		check(bool(presets.get_value(section, "permissions/vibrate")), "Permissão de vibração em " + section)
	check(not bool(presets.get_value("preset.0.options", "permissions/internet")), "Sem permissão de internet")
	check(int(presets.get_value("preset.0.options", "gradle_build/export_format")) == 0, "Preset APK")
	check(bool(presets.get_value("preset.1.options", "gradle_build/use_gradle_build")), "Gradle habilitado no AAB")
	check(presets.get_value("preset.1.options", "gradle_build/min_sdk") == "24", "Min SDK explícito no AAB")
	check(presets.get_value("preset.1.options", "gradle_build/target_sdk") == "36", "Target SDK explícito no AAB")
	check(int(presets.get_value("preset.1.options", "gradle_build/export_format")) == 1, "Preset AAB")

	var expected_icons := {
		"res://assets/sprites/app_icon_192.png": Vector2i(192, 192),
		"res://assets/sprites/app_icon_foreground_432.png": Vector2i(432, 432),
		"res://assets/sprites/app_icon_background_432.png": Vector2i(432, 432),
		"res://assets/sprites/app_icon_monochrome_432.png": Vector2i(432, 432),
	}
	for path: String in expected_icons:
		var texture := load(path) as Texture2D
		check(texture != null and texture.get_size() == Vector2(expected_icons[path]), "Dimensão do ícone " + path)

	check(FileAccess.file_exists("res://android/.gdignore"), "Modelo Gradle isolado do importador")
	check(FileAccess.file_exists("res://android/build/gradlew.bat"), "Modelo Gradle instalado")
	check(FileAccess.file_exists("res://build/vertical-1.0.0-release-candidate.apk"), "APK gerado")
	check(FileAccess.file_exists("res://build/vertical-1.0.0-debug-test.aab"), "AAB de teste gerado")
	print("FASE19 ANDROID: falhas = ", failures.size())
	quit(0 if failures.is_empty() else 1)
