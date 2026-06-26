extends RefCounted
class_name Level5Data

## Fase 5 - Becos Estreitos
## Controle aéreo severamente reduzido. Exige precisão no pulo.

static func get_data() -> Dictionary:
	return {
		"name": "Becos Estreitos",
		"description": "Pelos becos... o controle no ar é limitado.\nPense antes de pular!",
		"modifier_hint": "Controle Aéreo Reduzido  ·  Planeje seus pulos!",
		"ambient_type": "echo_urban",
		"dialogues": [
			{"speaker": "Bog", "text": "Esses becos são apertados..."},
			{"speaker": "Rob", "text": "Pule com cuidado, não podemos perder o Loopy."},
			{"speaker": "Rob", "text": "Venha comigo Bog!"},
		],
		"bg_color":       Color(0.742, 0.81, 0.794, 1.0),
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
			[990,  620, 200, 22],   # CHECKPOINT 1
			[1270, 570, 100, 18],
			[1450, 470, 100, 18],
			[1450, 270, 100, 18],
			[1800, 320, 200, 22],   # CHECKPOINT 2
			[2260, 385,  90, 18],
			[2600, 560, 380, 28],
		],
		"checkpoints": [
			[1050, 595],
			[1860, 290],
		],
		
		"switches": [
			[2, 1150, 608, 40, 12, true]
		],
		"gates": [
			[2, 1310, 370, 20, 200]
		],
		
		"stars": [
			[200, 410],
			[1500, 100],
			[1675, 320],
		],
		"exit_pos":    [2900, 520],
		"spawn_rob":   [50,   560],
		"spawn_bog":   [150,  560],
		"loopy_start": [2820, 510],
		"loopy_end":   [2900, 510],
	}
