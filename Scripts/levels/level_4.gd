extends RefCounted
class_name Level4Data

## Fase 4 - Becos Estreitos
## Controle aereo quase nulo: planeje antes de pular.

static func get_data() -> Dictionary:
	return {
		"name": "Becos Estreitos",
		"description": "Sem controle no ar!  Pense antes de pular!",
		"modifier_hint": "Controle Aéreo Mínimo",
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
			[0,    620, 200, 40],
			[300,  620, 100, 40],
			[500,  540,  80, 20],
			[680,  460,  80, 20],
			[860,  540,  80, 20],
			[1040, 620, 100, 40],
			[1200, 500,  80, 20],
			[1380, 400, 100, 20],
			[1580, 500,  80, 20],
			[1760, 620, 300, 40],
		],
		"exit_pos":   [1980, 580],
		"spawn_rob":  [50,   560],
		"spawn_bog":  [120,  560],
		"loopy_start":[1850, 580],
		"loopy_end":  [2200, 580],
	}
