extends Node

## GameManager - Autoload Singleton
## Gerencia estado global do jogo: niveis, mortes e fluxo de cenas.
## Os dados de cada fase estao em Scripts/levels/level_N.gd

enum GameState { MENU, PLAYING, PAUSED, GAME_COMPLETE }

var current_state:       GameState = GameState.MENU
var current_level_index: int       = 0
var deaths:              int       = 0   # contador de mortes (sem game over)
var stars_collected:     int       = 0   # total ao longo do jogo
var stars_in_level:      int       = 0   # da fase atual
var stars_total_game:    int       = 0   # soma de todas as fases
var collected_ids:       Dictionary = {}  # chave "idx:starIdx" -> true

signal level_changed(level_index: int)
signal state_changed(new_state: GameState)
signal deaths_changed(total: int)
signal stars_changed(collected: int, total_in_level: int)

var levels: Array[Dictionary] = []

func _ready() -> void:
	levels = [
		Level1Data.get_data(),
		Level2Data.get_data(),
		Level3Data.get_data(),
		Level4Data.get_data(),
		Level5Data.get_data(),
	]
	for lv in levels:
		stars_total_game += (lv.get("stars", []) as Array).size()

# ============================================================

func get_current_level() -> Dictionary:
	return levels[current_level_index]

func get_level_count() -> int:
	return levels.size()

func next_level() -> bool:
	current_level_index += 1
	if current_level_index >= levels.size():
		current_state = GameState.GAME_COMPLETE
		state_changed.emit(current_state)
		return false
	level_changed.emit(current_level_index)
	return true

func restart_level() -> void:
	level_changed.emit(current_level_index)

func register_death() -> void:
	deaths += 1
	deaths_changed.emit(deaths)

func start_game() -> void:
	current_level_index = 0
	deaths              = 0
	stars_collected     = 0
	collected_ids.clear()
	current_state       = GameState.PLAYING
	deaths_changed.emit(deaths)
	state_changed.emit(current_state)

func reset_game() -> void:
	current_level_index = 0
	deaths              = 0
	stars_collected     = 0
	collected_ids.clear()
	current_state       = GameState.MENU

func is_star_collected(level_idx: int, star_idx: int) -> bool:
	return collected_ids.has("%d:%d" % [level_idx, star_idx])

func collect_star(level_idx: int, star_idx: int) -> void:
	var key := "%d:%d" % [level_idx, star_idx]
	if collected_ids.has(key):
		return
	collected_ids[key] = true
	stars_collected += 1
	stars_changed.emit(stars_collected, stars_in_level)
