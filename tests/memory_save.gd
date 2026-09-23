extends "res://scripts/systems/save_manager.gd"

# O teste de conclusão nunca escreve no progresso real do jogador.
func _save() -> bool:
	return true
