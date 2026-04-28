extends RefCounted
class_name Level5Data

## Fase 5 - Encontro com Loopy
## Modificadores combinados em nivel desafiador mas justo. Loopy parado no final.

static func get_data() -> Dictionary:
	return {
		"name": "Encontro com Loopy",
		"description": "Ali está o Loopy! Ele parou...\nAlcance-o e traga seu amigo de volta!",
		"modifier_hint": "Velocidade  +  Gelo  +  Gravidade  ·  Tudo junto!",
		"bg_color":       Color(0.16, 0.10, 0.07),
		"platform_color": Color(0.70, 0.54, 0.28),
		"modifiers": {
			"speed_mult":   1.30,
			"jump_mult":    1.20,
			"gravity_mult": 1.25,
			"friction":     0.12,
			"air_control":  0.55,
		},
		"platforms": [
			[0,    620, 240, 28],
			[380,  530,  85, 18],
			[570,  440,  70, 18],
			[750,  530,  90, 18],
			[950,  445,  70, 18],
			[1110, 560, 180, 22],  # CHECKPOINT 1
			[1400, 465,  85, 18],
			[1600, 370,  80, 18],
			[1800, 465,  85, 18],
			[2000, 560, 180, 22],  # CHECKPOINT 2
			[2280, 465,  80, 18],
			[2470, 375,  70, 18],
			[2650, 465,  80, 18],
			[2850, 620, 450, 28],  # Plataforma final — Loopy aqui
		],
		"checkpoints": [
			[1170, 535],
			[2060, 535],
		],
		"hazards": [
			[ 280, 590,  90, 22],
			[ 480, 590,  80, 22],
			[ 660, 590,  80, 22],
			[ 850, 590, 100, 22],
			[1300, 590,  90, 22],
			[1500, 590,  90, 22],
			[1690, 590,  90, 22],
			[2200, 590, 100, 22],
			[2380, 590,  80, 22],
			[2560, 590,  90, 22],
			[2740, 590, 100, 22],
		],
		"pushable_blocks": [
			[140, 580, 40, 40],
		],
		"stars": [
			[615, 405],
			[1665, 335],
			[2535, 340],
			[220, 425],   # Estrela do Bog
		],
		"exit_pos":    [3100, 590],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [155,  560],
		"loopy_start": [3060, 572],
		"loopy_end":   [3060, 572],
	}
