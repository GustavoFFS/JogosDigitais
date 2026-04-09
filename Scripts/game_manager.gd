extends Node

## GameManager - Autoload Singleton
## Gerencia estado do jogo, niveis e modificadores de movimento.

enum GameState { MENU, PLAYING, LEVEL_INTRO, LEVEL_COMPLETE, GAME_COMPLETE, PAUSED }

var current_state: GameState = GameState.MENU
var current_level_index: int = 0
var lives: int = 3

# Sinal emitido quando o nivel muda
signal level_changed(level_index: int)
signal state_changed(new_state: GameState)
signal lives_changed(new_lives: int)

# ============================================================
# DEFINICAO DOS NIVEIS
# Cada nivel tem: nome, descricao, modificadores de movimento,
# plataformas, posicao de saida, spawns e aparicao do Loopy.
# ============================================================

var levels: Array[Dictionary] = [
	{
		"name": "Ruas da Cidade",
		"description": "Controles normais - aprenda a andar e pular!",
		"modifier_hint": "Movimento Normal",
		"bg_color": Color(0.15, 0.18, 0.28),
		"platform_color": Color(0.35, 0.38, 0.42),
		"modifiers": {
			"speed_mult": 1.0,
			"jump_mult": 1.0,
			"gravity_mult": 1.0,
			"friction": 1.0,
			"air_control": 1.0,
		},
		"platforms": [
			# [x, y, largura, altura]
			[0, 620, 500, 40],
			[200, 500, 120, 20],
			[420, 420, 120, 20],
			[600, 620, 300, 40],
			[750, 480, 100, 20],
			[950, 380, 120, 20],
			[1050, 620, 400, 40],
			[1250, 500, 120, 20],
			[1500, 620, 500, 40],
		],
		"exit_pos": [1900, 580],
		"spawn_rob": [80, 560],
		"spawn_bog": [160, 560],
		"loopy_start": [1700, 580],
		"loopy_end": [2100, 580],
	},
	{
		"name": "Praca Escorregadia",
		"description": "O chao esta escorregadio! Cuidado para nao cair!",
		"modifier_hint": "Baixa Friccao - Gelo!",
		"bg_color": Color(0.12, 0.2, 0.3),
		"platform_color": Color(0.5, 0.75, 0.85),
		"modifiers": {
			"speed_mult": 1.0,
			"jump_mult": 1.0,
			"gravity_mult": 1.0,
			"friction": 0.08,
			"air_control": 0.8,
		},
		"platforms": [
			[0, 620, 400, 40],
			[500, 620, 250, 40],
			[850, 620, 200, 40],
			[850, 480, 100, 20],
			[1050, 380, 120, 20],
			[1150, 620, 250, 40],
			[1500, 580, 150, 20],
			[1750, 620, 350, 40],
		],
		"exit_pos": [2000, 580],
		"spawn_rob": [80, 560],
		"spawn_bog": [160, 560],
		"loopy_start": [1800, 580],
		"loopy_end": [2200, 580],
	},
	{
		"name": "Telhados",
		"description": "Gravidade pesada, mas seus pulos sao mais fortes!",
		"modifier_hint": "Gravidade Alta + Pulo Forte",
		"bg_color": Color(0.08, 0.06, 0.15),
		"platform_color": Color(0.55, 0.3, 0.25),
		"modifiers": {
			"speed_mult": 1.0,
			"jump_mult": 1.5,
			"gravity_mult": 1.7,
			"friction": 1.0,
			"air_control": 1.0,
		},
		"platforms": [
			[0, 620, 250, 40],
			[350, 520, 120, 20],
			[550, 420, 120, 20],
			[350, 320, 120, 20],
			[600, 250, 150, 20],
			[850, 350, 120, 20],
			[1050, 500, 120, 20],
			[1250, 400, 150, 20],
			[1500, 300, 120, 20],
			[1700, 450, 120, 20],
			[1900, 620, 250, 40],
		],
		"exit_pos": [2050, 580],
		"spawn_rob": [60, 560],
		"spawn_bog": [140, 560],
		"loopy_start": [1950, 580],
		"loopy_end": [2300, 580],
	},
	{
		"name": "Becos Estreitos",
		"description": "Sem controle no ar! Pense antes de pular!",
		"modifier_hint": "Controle Aereo Minimo",
		"bg_color": Color(0.1, 0.1, 0.12),
		"platform_color": Color(0.4, 0.4, 0.35),
		"modifiers": {
			"speed_mult": 0.9,
			"jump_mult": 1.1,
			"gravity_mult": 1.0,
			"friction": 1.0,
			"air_control": 0.12,
		},
		"platforms": [
			[0, 620, 200, 40],
			[300, 620, 100, 40],
			[500, 540, 80, 20],
			[680, 460, 80, 20],
			[860, 540, 80, 20],
			[1040, 620, 100, 40],
			[1200, 500, 80, 20],
			[1380, 400, 100, 20],
			[1580, 500, 80, 20],
			[1760, 620, 300, 40],
		],
		"exit_pos": [1980, 580],
		"spawn_rob": [50, 560],
		"spawn_bog": [120, 560],
		"loopy_start": [1850, 580],
		"loopy_end": [2200, 580],
	},
	{
		"name": "Encontro com Loopy",
		"description": "Tudo junto! Escorregadio, rapido e pesado!",
		"modifier_hint": "Velocidade Alta + Gelo + Gravidade",
		"bg_color": Color(0.18, 0.12, 0.08),
		"platform_color": Color(0.7, 0.55, 0.3),
		"modifiers": {
			"speed_mult": 1.3,
			"jump_mult": 1.3,
			"gravity_mult": 1.4,
			"friction": 0.15,
			"air_control": 0.5,
		},
		"platforms": [
			[0, 620, 300, 40],
			[400, 540, 100, 20],
			[600, 450, 100, 20],
			[800, 540, 120, 20],
			[1000, 620, 200, 40],
			[1300, 520, 80, 20],
			[1480, 420, 100, 20],
			[1680, 320, 100, 20],
			[1880, 420, 80, 20],
			[2050, 520, 100, 20],
			[2200, 620, 350, 40],
		],
		"exit_pos": [2450, 580],
		"spawn_rob": [60, 560],
		"spawn_bog": [150, 560],
		"loopy_start": [2300, 580],
		"loopy_end": [2300, 580],  # Loopy fica parado no final!
	},
]

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

func restart_level():
	level_changed.emit(current_level_index)

func lose_life() -> bool:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		return false  # game over
	return true

func start_game():
	current_level_index = 0
	lives = 3
	current_state = GameState.PLAYING
	lives_changed.emit(lives)
	state_changed.emit(current_state)

func reset_game():
	current_level_index = 0
	lives = 3
	current_state = GameState.MENU
