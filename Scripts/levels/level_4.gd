extends RefCounted
class_name Level4Data

## Fase 4 - Telhados da Cidade
## Gravidade elevada e pulo forte. Introduz Jump Pads (molas).

static func get_data() -> Dictionary:
	return {
		"name": "Telhados da Cidade",
		"description": "Ele está nos telhados! Pule alto e cuidado com a queda rápida!",
		"modifier_hint": "Gravidade Elevada  +  Pulo Forte  ·  Use as molas!",
		"bg_color":       Color(0.742, 0.81, 0.794, 1.0),
		"bg_image": "res://Assets/Backgrounds/TelhadosdaCidade.png",
		"bg_size": [8000.0, 1080.0],
		"platform_color": Color(0.68, 0.26, 0.22),
		"modifiers": {
			"speed_mult":   1.0,
			"jump_mult":    1.25,
			"gravity_mult": 1.35,
			"friction":     1.0,
			"air_control":  1.0,
		},
		"platforms": [
			[0,    620, 280, 28],
			[360,  520, 120, 18],
			[560,  420, 110, 18],
			[760,  520, 120, 18],
			[970,  420, 100, 18],
			[1150, 545, 210, 22],   # CHECKPOINT
			[1440, 440, 120, 18],
			[1640, 340, 110, 18],
			[1840, 440, 120, 18],
			[2040, 545, 120, 18],
			[2230, 620, 360, 28],
		],
		"checkpoints": [
			[1210, 520],
		],
		"hazards": [
			[ 300, 590,  50, 22],
			[ 480, 510,  60, 22],
			[ 880, 590,  70, 22],
			[1370, 590,  60, 22],
			[1750, 510,  70, 22],
			[2150, 540,  60, 22],
		],
		"pushable_blocks": [
			[140, 580, 40, 40],
		],
		"jump_pads": [
			[240, 600, 30, 20],
			[1500, 420, 30, 20],
		],
		"stars": [
			[450, 385],
			[1690, 220],
			[2125, 415],
			[220, 410],   # Estrela do Bog
		],
		"exit_pos":    [2510, 572],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [150,  560],
		"loopy_start": [2360, 572],
		"loopy_end":   [2510, 572],
	}
