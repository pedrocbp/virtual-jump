class_name LevelConfig
extends Resource

@export var level_number: int = 1
@export var display_name: String = "Fase 1 - primeira fase"
@export var has_hazards: bool = false
@export_category("Medalhas")
@export var silver_time: float = 30.0
@export var gold_time: float = 22.0


func get_medal_rank(elapsed_seconds: float) -> int:
	if elapsed_seconds <= gold_time:
		return 3
	if elapsed_seconds <= silver_time:
		return 2
	return 1


func get_medal_name(rank: int) -> String:
	match rank:
		3:
			return "OURO"
		2:
			return "PRATA"
		1:
			return "BRONZE"
		_:
			return "-"
