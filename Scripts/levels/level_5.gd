extends RefCounted
class_name Level5Data

## Fase 5 - Encontro com Loopy
## Todos os modificadores combinados. Fase final.

static func get_data() -> Dictionary:
	return {
		"name": "Encontro com Loopy",
		"description": "Tudo junto!  Escorregadio, rápido e pesado!",
		"modifier_hint": "Velocidade Alta  +  Gelo  +  Gravidade",
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
			[0,    620, 300, 40],
			[400,  540, 100, 20],
			[600,  450, 100, 20],
			[800,  540, 120, 20],
			[1000, 620, 200, 40],
			[1300, 520,  80, 20],
			[1480, 420, 100, 20],
			[1680, 320, 100, 20],
			[1880, 420,  80, 20],
			[2050, 520, 100, 20],
			[2200, 620, 350, 40],
		],
		"exit_pos":   [2450, 580],
		"spawn_rob":  [60,   560],
		"spawn_bog":  [150,  560],
		"loopy_start":[2300, 580],
		"loopy_end":  [2300, 580],  # Loopy fica parado no final
	}
