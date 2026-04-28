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
			"jump_mult":    1.30,
			"gravity_mult": 1.50,
			"friction":     1.0,
			"air_control":  1.0,
		},
		"platforms": [
			[0,    620, 240, 28],
			[340,  520,  90, 18],
			[540,  420,  80, 18],
			[740,  520,  90, 18],
			[950,  420,  80, 18],
			[1130, 545, 180, 22],   # CHECKPOINT
			[1420, 440,  90, 18],
			[1620, 340,  80, 18],
			[1820, 440,  90, 18],
			[2020, 545, 100, 18],
			[2230, 620, 360, 28],
		],
		"checkpoints": [
			[1190, 520],
		],
		"hazards": [
			[ 280, 590,  60, 22],
			[ 470, 590,  70, 22],
			[ 680, 590,  60, 22],
			[ 870, 590,  80, 22],
			[1330, 590, 100, 22],
			[1740, 590,  80, 22],
			[2150, 590,  80, 22],
		],
		"pushable_blocks": [
			[140, 580, 40, 40],
		],
		"stars": [
			[450, 385],   # No gap após a primeira subida — gravidade alta dificulta
			[1670, 250],  # Bem acima da plataforma alta — pulo no limite
			[2125, 415],  # No gap final, gravidade puxa rápido
			[220, 410],   # Estrela do Bog
		],
		"exit_pos":    [2510, 580],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [150,  560],
		"loopy_start": [2360, 572],
		"loopy_end":   [2780, 572],
	}
