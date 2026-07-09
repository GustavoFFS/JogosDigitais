extends RefCounted
class_name Level7Data

## Fase 7 - Canteiro de Obras
## Plataformas móveis horizontais e verticais com gravidade reduzida (pulo flutuante).

static func get_data() -> Dictionary:
	return {
		"name": "Canteiro de Obras",
		"description": "Ferrugem, andaimes e guindastes em movimento...\nCalcule o tempo dos saltos sob gravidade flutuante!",
		"modifier_hint": "Gravidade Reduzida  ·  Calcule a inércia móvel!",
		"ambient_type": "construction",
		"dialogues": [
			{"speaker": "Bog", "text": "Olha esse chão balançando!"},
			{"speaker": "Rob", "text": "Vá com calma, me siga."},
			{"speaker": "Bog", "text": "O que é aquele mecanismo ali?"},
		],
		"bg_color":       Color(0.742, 0.81, 0.794, 1.0),
		"bg_image": "res://Assets/Backgrounds/CanteirodeObras.png",
		"dust_effect":    true,
		"bg_size": [8000.0, 1080.0],
		"platform_color": Color(0.82, 0.62, 0.12),
		"modifiers": {
			"speed_mult":   1.0,
			"jump_mult":    1.0,
			"gravity_mult": 0.82,
			"friction":     1.0,
			"air_control":  1.0,
		},
		"platforms": [
			[0,    620, 240, 28],
			[600,  440, 100, 18],
			[850,  460, 280, 22],   # CHECKPOINT
			[1900, 200, 18, 280],
			[3600, 540, 420, 28],
		],
		"moving_platforms": [
			{
				"start_pos": Vector2(320.0, 420.0),
				"end_pos":   Vector2(500.0, 420.0),
				"w": 100.0,
				"h": 18.0,
				"speed": 100.0,
				"to_end": true
			},
						{ 
				"start_pos": Vector2(1300.0, 480.0), 
				"end_pos": Vector2(3400.0, 480.0),   
				"w": 110.0, 
				"h": 18.0, 
				"speed": 180.0,
				"trigger_dist": 160.0,
				"one_way": true
			}
		],
		"jump_pads": [
			[200, 600, 30, 20],
			[2050, 560, 30, 20],
		],
		"checkpoints": [
		],
		"speed_pads": [
			[1800, 560, 40, 20, 2.0],   # Zona C — impulso horizontal para cruzar o gap
		],
		
		
		"hazards": [
			[ 240, 620, 5360, 28],
			[ 2500, 470, 100, 28],
			[ 3200, 470, 100, 28],
		],

		"switches": [
			[6, 850, 448, 40, 12, true],
			[5, 910, 448, 40, 12, true],
			[6, 970, 448, 40, 12, true],
			[6, 1030, 448, 40, 12, true],
			[6, 1090, 448, 40, 12, true],
		],
		"gates": [
			[5, 2980, 280, 20, 200],
			[6, 2980, 1000, 20, 200]
		],
		"hints": [
			[990, 350, "Escolha com sabedoria, somente um levará à vitória."],
		],

		"stars": [
			[410, 250],
			[1310, 340],
			[20, 360],   
		],
		"exit_pos":    [3900, 490],
		"spawn_rob":   [50,   560],
		"spawn_bog":   [150,  560],
		"loopy_start": [3780, 492],
		"loopy_end":   [3900, 492],
	}
