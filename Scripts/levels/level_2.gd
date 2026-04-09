extends RefCounted
class_name Level2Data

## Fase 2 - Praca Escorregadia
## Friccao muito baixa, simula gelo.

static func get_data() -> Dictionary:
	return {
		"name": "Praça Escorregadia",
		"description": "O chão está escorregadio! Cuidado para não cair!",
		"modifier_hint": "Baixa Fricção  (Gelo)",
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
			[0,    620, 400, 40],
			[500,  620, 250, 40],
			[850,  620, 200, 40],
			[850,  480, 100, 20],
			[1050, 380, 120, 20],
			[1150, 620, 250, 40],
			[1500, 580, 150, 20],
			[1750, 620, 350, 40],
		],
		"exit_pos":   [2000, 580],
		"spawn_rob":  [80,   560],
		"spawn_bog":  [160,  560],
		"loopy_start":[1800, 580],
		"loopy_end":  [2200, 580],
	}
