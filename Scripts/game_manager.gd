extends Node

## GameManager - Autoload Singleton
## Gerencia estado global do jogo: niveis, mortes e fluxo de cenas.
## Os dados de cada fase estao em Scripts/levels/level_N.gd

enum GameState { MENU, PLAYING, PAUSED, GAME_COMPLETE }

var current_state:        GameState = GameState.MENU
var current_level_index: int        = 0
var deaths:              int        = 0   # contador de mortes (sem game over)
var stars_collected:     int        = 0   # total ao longo do jogo
var stars_in_level:      int        = 0   # da fase atual
var stars_total_game:    int        = 0   # soma de todas as fases
var collected_ids:       Dictionary = {}  # chave "idx:starIdx" -> true
var elapsed_time:        float      = 0.0
var is_timer_active:     bool       = false

signal level_changed(level_index: int)
signal state_changed(new_state: GameState)
signal deaths_changed(total: int)
signal stars_changed(collected: int, total_in_level: int)

const SAVE_FILE_PATH = "user://lost_loopy_save.json"

var levels: Array[Dictionary] = []

# ============================================================
# INICIALIZACAO
# ============================================================

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	load_game()
	
	levels = [
		Level1Data.get_data(),
		Level2Data.get_data(),
		Level3Data.get_data(),
		Level4Data.get_data(),
		Level5Data.get_data(),
		Level6Data.get_data(),
		Level7Data.get_data(),
		Level8Data.get_data(),
		Level9Data.get_data(),
		Level10Data.get_data(),
<<<<<<< HEAD
		LevelSecretHouse.get_data(),
=======
>>>>>>> 95a70239ae1677ac88b33fb622bcd3768c4c8119
	]
	for lv in levels:
		if not lv.get("is_secret", false):
			stars_total_game += (lv.get("stars", []) as Array).size()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()

# ============================================================
# GAME LOOP (INPUT -> UPDATE -> RENDER)
# ============================================================

func _process(delta: float) -> void:
	_game_loop_input()
	_game_loop_update(delta)
	_game_loop_render()

## 1. ETAPA DE INPUT
func _game_loop_input() -> void:
	# Gerenciamento de inputs globais contínuos ou polleados
	# (ex: atalhos globais de debug, toggle de console, etc)
	if Input.is_action_just_pressed("toggle_fullscreen"):
		var mode = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

## 2. ETAPA DE UPDATE
func _game_loop_update(delta: float) -> void:
	if is_timer_active:
		elapsed_time += delta

## 3. ETAPA DE RENDER
func _game_loop_render() -> void:
	# Efeitos ou sobreposições de UI 100% independentes da cena atual
	pass

# ============================================================
# ACESSO A DADOS (GETTERS)
# ============================================================

func get_current_level() -> Dictionary:
	if levels.is_empty():
		return {}
	var idx: int = clamp(current_level_index, 0, levels.size() - 1)
	return levels[idx]

func get_level_count() -> int:
	var count = 0
	for lv in levels:
		if not lv.get("is_secret", false):
			count += 1
	return count

func is_star_collected(level_idx: int, star_idx: int) -> bool:
	return collected_ids.has("%d:%d" % [level_idx, star_idx])

# ============================================================
# GERENCIAMENTO DE ESTADO E FLUXO
# ============================================================

func save_game() -> void:
	var state = {
		"game_state": {
			"current_level_index": current_level_index,
			"deaths": deaths,
			"stars_collected": stars_collected,
			"collected_ids": collected_ids,
			"elapsed_time": elapsed_time
		},
		"settings": {
			"window_mode": DisplayServer.window_get_mode(),
			"window_size_x": DisplayServer.window_get_size().x,
			"window_size_y": DisplayServer.window_get_size().y
		}
	}
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(state))
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			var data = json.get_data()
			if data.has("game_state"):
				var gs = data["game_state"]
				current_level_index = int(gs.get("current_level_index", 0))
				deaths = int(gs.get("deaths", 0))
				stars_collected = int(gs.get("stars_collected", 0))
				collected_ids = gs.get("collected_ids", {})
				elapsed_time = float(gs.get("elapsed_time", 0.0))
				
			if data.has("settings"):
				var st = data["settings"]
				var mode = int(st.get("window_mode", DisplayServer.WINDOW_MODE_WINDOWED))
				DisplayServer.window_set_mode(mode)
				if mode != DisplayServer.WINDOW_MODE_FULLSCREEN and mode != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
					var sx = int(st.get("window_size_x", 1152))
					var sy = int(st.get("window_size_y", 648))
					DisplayServer.window_set_size(Vector2i(sx, sy))
					var screen_size = DisplayServer.screen_get_size()
					var window_size = DisplayServer.window_get_size()
					DisplayServer.window_set_position((screen_size - window_size) / 2)

func next_level() -> bool:
	var current_data := get_current_level()
	if current_data.has("next_level_override"):
		var target_name: String = current_data["next_level_override"]
		if goto_level_by_name(target_name):
			return true
			
	current_level_index += 1
	
	while current_level_index < levels.size() and levels[current_level_index].get("is_secret", false):
		current_level_index += 1

	if current_level_index >= levels.size():
		current_state = GameState.GAME_COMPLETE
		is_timer_active = false
		state_changed.emit(current_state)
		save_game()
		return false
	level_changed.emit(current_level_index)
	save_game()
	return true

func goto_level_by_name(level_name: String) -> bool:
	for i in range(levels.size()):
		if levels[i].get("name", "") == level_name:
			current_level_index = i
			level_changed.emit(current_level_index)
			return true
	return false

func restart_level() -> void:
	level_changed.emit(current_level_index)

func register_death() -> void:
	deaths += 1
	deaths_changed.emit(deaths)
	save_game()

func start_game() -> void:
	Engine.time_scale = 1.0
	current_level_index = 0
	deaths              = 0
	stars_collected     = 0
	collected_ids.clear()
	elapsed_time        = 0.0
	is_timer_active     = true
	current_state       = GameState.PLAYING
	deaths_changed.emit(deaths)
	state_changed.emit(current_state)
	save_game()

func continue_game() -> void:
	Engine.time_scale = 1.0
	is_timer_active = true
	current_state = GameState.PLAYING
	deaths_changed.emit(deaths)
	state_changed.emit(current_state)

func return_to_menu() -> void:
	Engine.time_scale = 1.0
	is_timer_active = false
	current_state = GameState.MENU
	save_game()

func reset_game() -> void:
	Engine.time_scale = 1.0
	current_level_index = 0
	deaths              = 0
	stars_collected     = 0
	collected_ids.clear()
	elapsed_time        = 0.0
	is_timer_active     = false
	current_state       = GameState.MENU
	save_game()

func collect_star(level_idx: int, star_idx: int) -> void:
	var key := "%d:%d" % [level_idx, star_idx]
	if collected_ids.has(key):
		return
	collected_ids[key] = true
	stars_collected += 1
	stars_changed.emit(stars_collected, stars_in_level)
	save_game()
