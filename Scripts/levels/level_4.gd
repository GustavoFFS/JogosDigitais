extends RefCounted
class_name Level4Data

## Fase 4 - Telhados da Cidade
## Gravidade elevada e pulo forte. Introduz Jump Pads (molas).

static func get_data() -> Dictionary:
	return {
		"name": "Telhados da Cidade",
		"description": "Ele está nos telhados! Pule alto e cuidado com a queda rápida!",
		"modifier_hint": "Gravidade Elevada  +  Pulo Forte  ·  Use as molas!",
		"ambient_type": "wind_high",
		"dialogues": [
			{"speaker": "Rob", "text": "Ele subiu pros telhados?!"},
			{"speaker": "Bog", "text": "Tô me sentindo mais leve aqui em cima..."},
		],
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
			[0,    620, 280, 28],   # Início
			[430,  460, 240, 18],
			[1150, 545, 210, 22],   # Checkpoint
			[1440, 440, 120, 18],   # Plataforma Alta
			[1640, 340, 110, 18],   # Plataforma Alta
			[1840, 440, 120, 18],   # Plataforma Alta
			[1500, 640, 120, 18],   # Plataforma Baixa
			[1780, 600, 120, 18],   # Plataforma Baixa
			[2000, 680, 120, 18],   # Plataforma Baixa
			[2230, 620, 360, 28],   # Final
			[2230, 400, 18, 298],   # Parede Final
		],
		"checkpoints": [
			[1210, 520],
		],
		"hazards": [
			[ 1560, 436,  280, 22],
			[ 2120, 676,  110, 22],
		],
		"crumbling_platforms": [
			[ 890, 500,  60, 18],
		],
		"secret_exits": [
			[ 880, 650,  80, 122, "Casa Misteriosa" ],
		],
		"pushable_blocks": [
			[140, 580, 40, 40],
		],
		"keys": [
			[1, 2060, 600],
		],
		"locks": [
			[1, 1680, 160, 30, 180],
		],
		"jump_pads": [
			[1930, 420, 30, 20],
		],
		
		"speed_pads": [
			[1100, 700, 40, 20, -2.0],   # Zona C — impulso horizontal para cruzar o gap
		],
		
		"stars": [
			[220, 410],   # OK
			[1695, 220],   # OK
			[2060, 449],   # OK
			[2239, 300],   # OK
		],
		"exit_pos":    [2510, 572],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [100,  560],
		"loopy_start": [2360, 572],
		"loopy_end":   [2510, 572],
	}
