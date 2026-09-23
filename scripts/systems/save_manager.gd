extends Node

const Catalog := preload("res://scripts/systems/level_catalog.gd")
const Skins := preload("res://scripts/systems/skin_catalog.gd")

signal settings_changed
signal skin_changed

const SAVE_PATH := "user://jogo_save.json"
# Builds de depuração liberam todas as fases para testes. Builds release da loja
# sempre usam a progressão normal, sem depender de uma troca manual de flag.
const DEFAULT_SETTINGS := {
	"music_enabled": true, "sfx_enabled": true, "vibration_enabled": true,
	"master_volume": 1.0, "music_volume": 1.0, "sfx_volume": 1.0, "muted": false,
	"visual_theme": 0, "tutorial_seen": false
}

var highest_unlocked_level: int = 1
var completed_levels: Array[int] = []
var best_times: Dictionary = {}
var best_medals: Dictionary = {}
var endless_best_blocks: int = 0
var total_attempts: int = 0
var total_deaths: int = 0
var attempts_by_level: Dictionary = {}
var selected_skin := "classic"
var tutorial_next_scene := ""
var settings: Dictionary = DEFAULT_SETTINGS.duplicate()

func _ready() -> void:
	_load_save()

func record_completion(level_number: int, elapsed_seconds: float, medal_rank: int = 1) -> void:
	if level_number < 1 or level_number > Catalog.TOTAL_LEVELS or not is_finite(elapsed_seconds) or elapsed_seconds < 0:
		return
	if not completed_levels.has(level_number):
		completed_levels.append(level_number)
	highest_unlocked_level = maxi(highest_unlocked_level, mini(Catalog.TOTAL_LEVELS, level_number + 1))
	var key := str(level_number)
	if not best_times.has(key) or elapsed_seconds < float(best_times[key]):
		best_times[key] = elapsed_seconds
	if not best_medals.has(key) or medal_rank > int(best_medals[key]):
		best_medals[key] = clampi(medal_rank, 1, 3)
	_save()

func is_level_unlocked(level_number: int) -> bool:
	if OS.is_debug_build():
		return level_number >= 1 and level_number <= Catalog.TOTAL_LEVELS
	return level_number >= 1 and level_number <= highest_unlocked_level

func get_best_time(level_number: int) -> float:
	return float(best_times.get(str(level_number), -1.0))

func get_best_medal(level_number: int) -> int:
	return int(best_medals.get(str(level_number), 0))

func get_endless_best_blocks() -> int:
	return endless_best_blocks

func record_endless_best(blocks: int) -> bool:
	var clean_blocks := maxi(0, blocks)
	if clean_blocks <= endless_best_blocks:
		return false
	endless_best_blocks = clean_blocks
	_save()
	return true

func record_attempt(level_number: int) -> void:
	if level_number < 0 or level_number > Catalog.TOTAL_LEVELS:
		return
	total_attempts += 1
	var key := str(level_number)
	attempts_by_level[key] = int(attempts_by_level.get(key, 0)) + 1
	_save()

func record_death() -> void:
	total_deaths += 1
	_save()

func get_attempts(level_number: int) -> int:
	return int(attempts_by_level.get(str(level_number), 0))

func get_medal_name(rank: int) -> String:
	return ["—", "BRONZE", "PRATA", "OURO"][clampi(rank, 0, 3)]

func is_level_completed(level_number: int) -> bool:
	return completed_levels.has(level_number)

func is_skin_unlocked(skin_id: String) -> bool:
	if not Skins.has_skin(skin_id):
		return false
	var skin := Skins.get_skin(skin_id)
	var requirement := String(skin["unlock_type"])
	var required_value := int(skin["unlock_value"])
	match requirement:
		"free":
			return true
		"levels":
			return completed_levels.size() >= required_value
		"golds":
			var golds := 0
			for medal in best_medals.values():
				if int(medal) == 3:
					golds += 1
			return golds >= required_value
		"endless":
			return endless_best_blocks >= required_value
		"all_levels":
			return completed_levels.size() >= Catalog.TOTAL_LEVELS
	return false

func get_unlocked_skin_count() -> int:
	var total := 0
	for skin_value in Skins.all():
		if is_skin_unlocked(String(skin_value["id"])):
			total += 1
	return total

func select_skin(skin_id: String) -> bool:
	if not is_skin_unlocked(skin_id):
		return false
	if selected_skin == skin_id:
		return true
	var previous := selected_skin
	selected_skin = skin_id
	if not _save():
		selected_skin = previous
		return false
	skin_changed.emit()
	return true

func set_setting(key: String, value: Variant) -> bool:
	if not DEFAULT_SETTINGS.has(key):
		return false
	var clean: Variant = _setting_value(key, value)
	var previous: Variant = settings[key]
	settings[key] = clean
	if not _save():
		settings[key] = previous
		return false
	settings_changed.emit()
	return true

func _setting_value(key: String, value: Variant) -> Variant:
	if key == "visual_theme":
		return clampi(int(value), 0, 2) if typeof(value) in [TYPE_INT, TYPE_FLOAT] else DEFAULT_SETTINGS[key]
	if typeof(DEFAULT_SETTINGS[key]) == TYPE_BOOL:
		return value if typeof(value) == TYPE_BOOL else DEFAULT_SETTINGS[key]
	if typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)):
		return clampf(float(value), 0.0, 1.0)
	return DEFAULT_SETTINGS[key]

func reset_progress() -> bool:
	var previous := _serialize()
	highest_unlocked_level = 1
	completed_levels.clear()
	best_times.clear()
	best_medals.clear()
	endless_best_blocks = 0
	total_attempts = 0
	total_deaths = 0
	attempts_by_level.clear()
	selected_skin = "classic"
	if _save():
		skin_changed.emit()
		return true
	_restore(previous)
	return false

func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_restore(parsed)

func _restore(data: Dictionary) -> void:
	var unlocked: Variant = data.get("highest_unlocked_level", 1)
	highest_unlocked_level = clampi(int(unlocked), 1, Catalog.TOTAL_LEVELS) if typeof(unlocked) in [TYPE_INT, TYPE_FLOAT] else 1
	completed_levels.clear()
	var completed: Variant = data.get("completed_levels", [])
	if completed is Array:
		for value in completed:
			if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
				continue
			var number := int(value)
			if number >= 1 and number <= Catalog.TOTAL_LEVELS and not completed_levels.has(number):
				completed_levels.append(number)
	best_times.clear()
	var times: Variant = data.get("best_times", {})
	if times is Dictionary:
		for key in times:
			var value: Variant = times[key]
			if typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) and float(value) >= 0:
				best_times[str(key)] = float(value)
	best_medals.clear()
	var medals: Variant = data.get("best_medals", {})
	if medals is Dictionary:
		for key in medals:
			if typeof(medals[key]) in [TYPE_INT, TYPE_FLOAT]:
				best_medals[str(key)] = clampi(int(medals[key]), 1, 3)
	var endless_best: Variant = data.get("endless_best_blocks", 0)
	endless_best_blocks = maxi(0, int(endless_best)) if typeof(endless_best) in [TYPE_INT, TYPE_FLOAT] else 0
	var attempts: Variant = data.get("total_attempts", 0)
	total_attempts = maxi(0, int(attempts)) if typeof(attempts) in [TYPE_INT, TYPE_FLOAT] else 0
	var deaths: Variant = data.get("total_deaths", 0)
	total_deaths = maxi(0, int(deaths)) if typeof(deaths) in [TYPE_INT, TYPE_FLOAT] else 0
	attempts_by_level.clear()
	var attempts_data: Variant = data.get("attempts_by_level", {})
	if attempts_data is Dictionary:
		for key in attempts_data:
			if typeof(attempts_data[key]) in [TYPE_INT, TYPE_FLOAT]:
				attempts_by_level[str(key)] = maxi(0, int(attempts_data[key]))
	settings = DEFAULT_SETTINGS.duplicate()
	var loaded_settings: Variant = data.get("settings", {})
	if loaded_settings is Dictionary:
		for key in DEFAULT_SETTINGS:
			settings[key] = _setting_value(key, loaded_settings.get(key, DEFAULT_SETTINGS[key]))
	var loaded_skin: Variant = data.get("selected_skin", "classic")
	selected_skin = String(loaded_skin) if typeof(loaded_skin) == TYPE_STRING else "classic"
	if not is_skin_unlocked(selected_skin):
		selected_skin = "classic"

func _serialize() -> Dictionary:
	return {
		"highest_unlocked_level": highest_unlocked_level,
		"completed_levels": completed_levels.duplicate(),
		"best_times": best_times.duplicate(),
		"best_medals": best_medals.duplicate(),
		"endless_best_blocks": endless_best_blocks,
		"total_attempts": total_attempts,
		"total_deaths": total_deaths,
		"attempts_by_level": attempts_by_level.duplicate(),
		"selected_skin": selected_skin,
		"settings": settings.duplicate()
	}

func _save() -> bool:
	return _write_save(SAVE_PATH)

func _write_save(path: String) -> bool:
	# Publica o novo arquivo só depois da escrita completa; mantém o anterior em caso de falha.
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(_serialize(), "\t"))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return false
	return DirAccess.rename_absolute(temporary, path) == OK
