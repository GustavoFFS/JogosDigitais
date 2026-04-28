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
			"speed_mult":   0.85,
			"jump_mult":    1.05,
			"gravity_mult": 1.0,
			"friction":     1.0,
			"air_control":  0.20,
		},
		"platforms": [
			[0,    620, 200, 28],
			[300,  535,  80, 18],
			[470,  455,  70, 18],
			[630,  535,  85, 18],
			[810,  455,  70, 18],
			[970,  560, 180, 22],   # CHECKPOINT 1
			[1250, 475,  80, 18],
			[1430, 380,  70, 18],
			[1600, 475,  80, 18],
			[1780, 560, 180, 22],   # CHECKPOINT 2
			[2060, 475,  80, 18],
			[2240, 380,  70, 18],
			[2410, 480,  80, 18],
			[2600, 560, 380, 28],
		],
		"checkpoints": [
			[1030, 535],
			[1840, 535],
		],
		"hazards": [
			[ 220, 590,  70, 22],
			[ 400, 590,  60, 22],
			[ 560, 590,  60, 22],
			[ 740, 590,  60, 22],
			[ 900, 590,  60, 22],
			[1370, 590,  60, 22],
			[1690, 590,  80, 22],
			[2150, 590,  80, 22],
			[2510, 590,  80, 22],
		],
		"pushable_blocks": [
			[100, 580, 40, 40],
		],
		"stars": [
			[535, 420],
			[1495, 350],
			[2305, 350],
			[200, 445],   # Estrela do Bog
		],
		"exit_pos":    [2900, 580],
		"spawn_rob":   [50,   560],
		"spawn_bog":   [130,  560],
		"loopy_start": [2760, 572],
		"loopy_end":   [3180, 572],
	}
