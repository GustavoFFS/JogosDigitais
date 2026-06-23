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
			{"speaker": "Bog", "text": "Olha esses andaimes balançando!"},
			{"speaker": "Rob", "text": "Calcula o tempo do pulo!"},
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
			[950,  460, 180, 22],   # CHECKPOINT
			[1550, 620, 320, 28],
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
				"start_pos": Vector2(800.0, 520.0),
				"end_pos":   Vector2(800.0, 340.0),
				"w": 90.0,
				"h": 18.0,
				"speed": 120.0,
				"to_end": true
			},
			{
				"start_pos": Vector2(1180.0, 480.0),
				"end_pos":   Vector2(1440.0, 480.0),
				"w": 100.0,
				"h": 18.0,
				"speed": 140.0,
				"to_end": true
			}
		],
		"jump_pads": [
			[200, 600, 30, 20],
		],
		"checkpoints": [
			[1040, 435],
		],
		"hazards": [
			[ 240, 590, 360, 22],
			[ 720, 590, 230, 22],
			[1130, 590, 420, 22],
		],
		"pushable_blocks": [
			[100, 580, 40, 40],
		],
		"stars": [
			[410, 300],
			[845, 220],
			[1310, 340],
			[200, 420],   # Estrela do Bog (flutuante sob a mola)
		],
		"exit_pos":    [1770, 570],
		"spawn_rob":   [50,   560],
		"spawn_bog":   [150,  560],
		"loopy_start": [1600, 572],
		"loopy_end":   [1760, 572],
	}
