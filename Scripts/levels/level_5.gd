extends RefCounted
class_name Level5Data

## Fase 5 - Becos Estreitos
## Controle aéreo severamente reduzido. Exige precisão no pulo.

static func get_data() -> Dictionary:
	return {
		"name": "Becos Estreitos",
		"description": "Pelos becos... o controle no ar é limitado.\nPense antes de pular!",
		"modifier_hint": "Controle Aéreo Reduzido  ·  Planeje seus pulos!",
		"bg_color":       Color(0.06, 0.07, 0.09),
		"bg_image": "res://Assets/Backgrounds/BecosEstreitos.png",
		"bg_size": [8000.0, 1080.0],
		"platform_color": Color(0.24, 0.26, 0.30),
		"modifiers": {
			"speed_mult":   0.90,
			"jump_mult":    1.10,
			"gravity_mult": 1.0,
			"friction":     1.0,
			"air_control":  0.28,
		},
		"platforms": [
			[0,    620, 240, 28],
			[320,  535, 100, 18],
			[490,  455,  90, 18],
			[650,  535, 110, 18],
			[830,  455,  90, 18],
			[990,  560, 200, 22],   # CHECKPOINT 1
			[1270, 475, 100, 18],
			[1450, 385,  90, 18],
			[1620, 475, 100, 18],
			[1800, 560, 200, 22],   # CHECKPOINT 2
			[2080, 475, 100, 18],
			[2260, 385,  90, 18],
			[2430, 480, 100, 18],
			[2600, 560, 380, 28],
		],
		"checkpoints": [
			[1050, 535],
			[1860, 535],
		],
		"hazards": [
			[ 430, 590,  50, 22],
			[ 750, 590,  60, 22],
			[1370, 590,  60, 22],
			[1700, 540,  70, 22],
			[2160, 540,  70, 22],
			[2520, 540,  70, 22],
		],
		"pushable_blocks": [
			[100, 580, 40, 40],
		],
		"stars": [
			[400, 420],
			[1490, 260],
			[2330, 260],
			[200, 445],   # Estrela do Bog
		],
		"exit_pos":    [2900, 520],
		"spawn_rob":   [50,   560],
		"spawn_bog":   [130,  560],
		"loopy_start": [2820, 510],
		"loopy_end":   [2900, 510],
	}
