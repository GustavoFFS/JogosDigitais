extends RefCounted
class_name Level3Data

## Fase 3 - Telhados
## Gravidade pesada compensada por pulos mais altos.

static func get_data() -> Dictionary:
	return {
		"name": "Telhados",
		"description": "Gravidade pesada, mas seus pulos são mais fortes!",
		"modifier_hint": "Gravidade Alta  +  Pulo Forte",
		"bg_color": Color(0.08, 0.06, 0.15),
		"platform_color": Color(0.55, 0.3, 0.25),
		"modifiers": {
			"speed_mult": 1.0,
			"jump_mult": 1.5,
			"gravity_mult": 1.7,
			"friction": 1.0,
			"air_control": 1.0,
		},
		"platforms": [
			[0,    620, 250, 40],
			[350,  520, 120, 20],
			[550,  420, 120, 20],
			[350,  320, 120, 20],
			[600,  250, 150, 20],
			[850,  350, 120, 20],
			[1050, 500, 120, 20],
			[1250, 400, 150, 20],
			[1500, 300, 120, 20],
			[1700, 450, 120, 20],
			[1900, 620, 250, 40],
		],
		"exit_pos":   [2050, 580],
		"spawn_rob":  [60,   560],
		"spawn_bog":  [140,  560],
		"loopy_start":[1950, 580],
		"loopy_end":  [2300, 580],
	}
