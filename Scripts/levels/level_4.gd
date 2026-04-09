extends RefCounted
class_name Level4Data

## Fase 4 - Becos Estreitos
## Controle aereo reduzido, mas jogavel. Plataformas mais largas que antes.

static func get_data() -> Dictionary:
	return {
		"name": "Becos Estreitos",
		"description": "Pelos becos... o controle no ar é limitado.\nPense antes de pular!",
		"modifier_hint": "Controle Aéreo Reduzido  ·  Planeje seus pulos!",
		"bg_color":       Color(0.09, 0.09, 0.11),
		"platform_color": Color(0.42, 0.42, 0.36),
		"modifiers": {
			"speed_mult":   0.9,
			"jump_mult":    1.1,
			"gravity_mult": 1.0,
			"friction":     1.0,
			"air_control":  0.30,
		},
		"platforms": [
			[0,    620, 240, 28],
			[320,  535, 100, 18],
			[490,  455, 90,  18],
			[650,  535, 110, 18],
			[830,  455, 90,  18],
			[990,  560, 200, 22],   # CHECKPOINT 1
			[1270, 475, 100, 18],
			[1450, 385, 90,  18],
			[1620, 475, 100, 18],
			[1800, 560, 200, 22],   # CHECKPOINT 2
			[2080, 475, 100, 18],
			[2260, 385, 90,  18],
			[2430, 480, 100, 18],
			[2600, 560, 380, 28],
		],
		"checkpoints": [
			[1050, 535],
			[1860, 535],
		],
		"hazards": [
			[415, 592, 50, 22],
			[745, 592, 60, 22],
			[1370, 592, 55, 22],
		],
		"exit_pos":    [2900, 580],
		"spawn_rob":   [50,   560],
		"spawn_bog":   [130,  560],
		"loopy_start": [2760, 572],
		"loopy_end":   [3180, 572],
	}
