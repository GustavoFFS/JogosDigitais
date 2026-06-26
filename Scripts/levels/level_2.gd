extends RefCounted
class_name Level2Data

## Fase 2 - Praça Escorregadia
## Friccao muito baixa. Loopy foi avistado deslizando pela praca.

static func get_data() -> Dictionary:
	return {
		"name": "Praça Escorregadia",
		"description": "Loopy foi avistado deslizando pela praça...\no chão gelado dificulta cada passo!",
		"modifier_hint": "Baixa Fricção  ·  Cuidado com o deslize!",
		"ambient_type": "wind_cold",
		"dialogues": [
			{"speaker": "Rob", "text": "Cuidado, o chão tá escorregando!"},
			{"speaker": "Bog", "text": "Já percebi... quase caí! Que frio!"},
			{"speaker": "Rob", "text": "Vamos juntos, essa mochila pesada deve ajudar..."},
			{"speaker": "Rob", "text": "Espera... O que é aquela ventania ali na frente?"},
			{"speaker": "Bog", "text": "Vamos lá descobrir..."},
		],
		"bg_color":       Color(0.742, 0.81, 0.794, 1.0),
		"bg_image": "res://Assets/Backgrounds/PracaEscorregadia.png", # <--- ADICIONE AQUI
		"bg_size": [5000.0, 500.0], # Vai repetir a imagem horizontalmente por 8000 pixels!
		"platform_color": Color(0.55, 0.85, 0.95),
		"snow_effect": true,
		"modifiers": {
			"speed_mult":   1.0,
			"jump_mult":    1.0,
			"gravity_mult": 1.0,
			"friction":     0.10,
			"air_control":  0.78,
		},
		"platforms": [
			[0,    620, 320, 28],
			[580,  300, 130, 18],
			[692,  300,  18, 318],
			[910,  -300,  18, 700],
			[710, 600,  350, 18],   # Checkpoint
			[1550, 250, 220, 18],   
			[2000, 310, 130, 18],
			[2350, 440, 100, 18],
			[2750, 600, 380, 18],   # Final
		],
			"moving_platforms": [
				{ 
					"start_pos": Vector2(460.0, 620.0), # Antigos x_min e y
					"end_pos": Vector2(460.0, 300.0),   # Antigos x_max e y
					"w": 110.0, 
					"h": 18.0, 
					"speed": 120.0,
					"to_end": true 
				},
			],

		"checkpoints": [
			[885, 570],
		],
		"hazards": [
			[ 320, 610,  80, 38],
			[ 1060, 590,  1690, 28],
		],
		
		"breakable_blocks": [
			[710, 300,  200, 28]
		],
		
		"gravity_zones": [
			[1150, 235, 300, 330],   # Zona 1 — cobre plataformas de teto 1-3
		],

		"pushable_blocks": [
			[180, 580, 40, 40],
		],
		"stars": [
			[810, 150],   # No gap deslizante após o início — escorregar e cair = morte
			[1300, 100],  # Bem acima da plataforma 1640/380
			[200, 200],  # No gap final — desliza demais e cai no espinho
			[2240, 220],   # Estrela do Bog
		],
		"exit_pos":    [3040, 560],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [160,  560],
		"loopy_start": [2880, 552],
		"loopy_end":   [3080, 552],
	}
