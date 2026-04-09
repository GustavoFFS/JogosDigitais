extends Node

## GameManager - Autoload Singleton
## Gerencia estado global do jogo: niveis, vidas e fluxo de cenas.
## Os dados de cada fase estao em Scripts/levels/level_N.gd

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER, GAME_COMPLETE }

var current_state:       GameState = GameState.MENU
var current_level_index: int       = 0
var lives:               int       = 3

signal level_changed(level_index: int)
signal state_changed(new_state: GameState)
signal lives_changed(new_lives: int)

var levels: Array[Dictionary] = []

func _ready() -> void:
	levels = [
		Level1Data.get_data(),
		Level2Data.get_data(),
		Level3Data.get_data(),
		Level4Data.get_data(),
		Level5Data.get_data(),
	]

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

func lose_life() -> bool:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		current_state = GameState.GAME_OVER
		return false
	return true

func start_game() -> void:
	current_level_index = 0
	lives               = 3
	current_state       = GameState.PLAYING
	lives_changed.emit(lives)
	state_changed.emit(current_state)

func reset_game() -> void:
	current_level_index = 0
	lives               = 3
	current_state       = GameState.MENU
