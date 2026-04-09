extends RefCounted
class_name Level1Data

## Fase 1 - Ruas da Cidade
## Controles normais, serve como tutorial.

static func get_data() -> Dictionary:
	return {
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
			[0,    620, 500, 40],
			[200,  500, 120, 20],
			[420,  420, 120, 20],
			[600,  620, 300, 40],
			[750,  480, 100, 20],
			[950,  380, 120, 20],
			[1050, 620, 400, 40],
			[1250, 500, 120, 20],
			[1500, 620, 500, 40],
		],
		"exit_pos":   [1900, 580],
		"spawn_rob":  [80,   560],
		"spawn_bog":  [160,  560],
		"loopy_start":[1700, 580],
		"loopy_end":  [2100, 580],
	}
