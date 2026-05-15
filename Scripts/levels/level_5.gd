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
			"speed_mult":   1.20,
			"jump_mult":    1.20,
			"gravity_mult": 1.20,
			"friction":     0.18,
			"air_control":  0.65,
		},
		"platforms": [
			[0,    620, 280, 28],
			[380,  530, 110, 18],
			[570,  440,  90, 18],
			[750,  530, 120, 18],
			[950,  445,  90, 18],
			[1130, 560, 200, 22],  # CHECKPOINT 1
			[1420, 465, 110, 18],
			[1620, 370, 100, 18],
			[1820, 465, 110, 18],
			[2020, 560, 200, 22],  # CHECKPOINT 2
			[2300, 465, 100, 18],
			[2490, 375,  90, 18],
			[2670, 465, 100, 18],
			[2850, 620, 450, 28],  # Plataforma final — Loopy aqui
		],
		"checkpoints": [
			[1190, 535],
			[2080, 535],
		],
		"hazards": [
			[ 320, 590,  60, 22],
			[ 700, 510,  50, 22],
			[ 880, 590,  60, 22],
			[1340, 540,  60, 22],
			[1740, 440,  60, 22],
			[2160, 540,  60, 22],
			[2580, 440,  60, 22],
			[2750, 590,  80, 22],
		],
		"pushable_blocks": [
			[140, 580, 40, 40],
		],
		"stars": [
			[510, 380],
			[1685, 245],  # Acima da plataforma alta
			[2560, 245],  # Acima da segunda plataforma alta
			[220, 425],   # Estrela do Bog
		],
		"exit_pos":    [3100, 590],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [155,  560],
		"loopy_start": [3060, 572],
		"loopy_end":   [3060, 572],
	}
