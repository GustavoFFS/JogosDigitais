extends RefCounted
class_name Level3Data

## Fase 3 - Telhados
## Gravidade moderada com pulo mais alto. Dificuldade intermediaria.

static func get_data() -> Dictionary:
	return {
		"name": "Telhados",
		"description": "Ele está nos telhados! Pule alto e cuidado com a queda rápida!",
		"modifier_hint": "Gravidade Elevada  +  Pulo Forte",
		"bg_color":       Color(0.07, 0.06, 0.14),
		"platform_color": Color(0.56, 0.30, 0.24),
		"modifiers": {
			"speed_mult":   1.0,
			"jump_mult":    1.25,
			"gravity_mult": 1.35,
			"friction":     1.0,
			"air_control":  1.0,
		},
		"platforms": [
			[0,    620, 280, 28],
			[360,  520, 120, 18],
			[560,  420, 110, 18],
			[760,  520, 120, 18],
			[970,  420, 100, 18],
			[1150, 545, 210, 22],   # CHECKPOINT
			[1440, 440, 120, 18],
			[1640, 340, 110, 18],
			[1840, 440, 120, 18],
			[2040, 545, 120, 18],
			[2230, 620, 360, 28],
		],
		"checkpoints": [
			[1210, 520],
		],
		"hazards": [
			[480, 592, 50, 22],
			[870, 592, 70, 22],
		],
		"pushable_blocks": [
			[140, 580, 40, 40],
		],
		"stars": [
			[615, 385],
			[1695, 305],
			[2090, 510],
			[220, 410],   # Estrela do Bog
		],
		"exit_pos":    [2510, 580],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [150,  560],
		"loopy_start": [2360, 572],
		"loopy_end":   [2780, 572],
	}
