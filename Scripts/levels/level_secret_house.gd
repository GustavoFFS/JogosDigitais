extends RefCounted
class_name LevelSecretHouse

## Fase Secreta - Casa Misteriosa
## Acessada a partir de uma queda falsa nos Telhados.

static func get_data() -> Dictionary:
	return {
		"name": "Casa Misteriosa",
		"description": "Você encontrou uma passagem secreta!\nUm lugar estranho e fechado...",
		"is_secret": true,
		"is_indoor": true,
		"modifier_hint": "Exploração  ·  Relaxe e pegue as estrelas!",
		"ambient_type": "echo_urban",
		"dialogues": [
			{"speaker": "Rob", "text": "Como viemos parar aqui dentro?"},
			{"speaker": "Bog", "text": "Parece uma casa abandonada... e tem estrelas extras!"},
		],
		"bg_color":       Color(0.12, 0.11, 0.13),
		"bg_size": [1600.0, 1080.0],
		"platform_color": Color(0.35, 0.28, 0.22),
		"modifiers": {
			"speed_mult":   0.90,
			"jump_mult":    1.0,
			"gravity_mult": 1.0,
			"friction":     1.0,
			"air_control":  1.0,
		},
		"dark_mode": true,
		"light_switches": [
			[850, 260, 40, 40]
		],
		"platforms": [
			# Chão principal
			[0,    620, 1400, 28],
			# Paredes
			[-20,    0,   20, 640],
			[1400,   0,   20, 640],
			# Prateleiras / andares
			[200,  500, 200, 15],
			[500,  400, 150, 15],
			[800,  300, 200, 15],
			[1100, 450, 180, 15],
		],
		"moving_platforms": [
			{
				"start_pos": Vector2(80.0, 600.0),
				"end_pos": Vector2(80.0, 500.0),
				"w": 80.0,
				"h": 15.0,
				"speed": 50.0,
				"to_end": true
			},
			{
				"start_pos": Vector2(420.0, 500.0),
				"end_pos": Vector2(420.0, 400.0),
				"w": 80.0,
				"h": 15.0,
				"speed": 50.0,
				"to_end": true
			},
			{
				"start_pos": Vector2(720.0, 400.0),
				"end_pos": Vector2(720.0, 300.0),
				"w": 80.0,
				"h": 15.0,
				"speed": 50.0,
				"to_end": true
			},
			{
				"start_pos": Vector2(1030.0, 300.0),
				"end_pos": Vector2(1030.0, 450.0),
				"w": 80.0,
				"h": 15.0,
				"speed": 60.0,
				"to_end": true
			}
		],
		"stars": [
			[250, 450],
			[550, 350],
			[850, 250],
			[1150, 400],
		],
		"spiders": [
			[460, 100, 450, 140.0],
			[750, 100, 450, 180.0],
			[1060, 100, 450, 120.0]
		],
		"exit_pos":    [1300, 570],
		"spawn_rob":   [80,   560],
		"spawn_bog":   [140,  560],
		"loopy_start": [1200, 570],
		"loopy_end":   [1300, 570],
		"next_level_override": "Becos Estreitos"
	}

