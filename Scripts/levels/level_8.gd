extends RefCounted
class_name Level8Data

## Fase 8 - Parque Central
## Combina física de gelo (fricção muito baixa) com puzzles de botões e portões.

static func get_data() -> Dictionary:
	return {
		"name": "Parque Central",
		"description": "O gramado do parque está coberto por uma camada fina de gelo...\nDeslize e ative os botões para abrir caminho!",
		"modifier_hint": "Super Deslize  +  Portões de Energia",
		"ambient_type": "park_wind",
		"dialogues": [
			{"speaker": "Rob", "text": "O parque congelou também?"},
			{"speaker": "Bog", "text": "Tem um botão ali, deixe comigo."},
			{"speaker": "Rob", "text": "Vá Bog, pegue aquele garoto encrenqueiro."},
		],
		"bg_color":       Color(0.742, 0.81, 0.794, 1.0),
		"bg_image": "res://Assets/Backgrounds/ParqueCentral.png",
		"bg_size": [8000.0, 1080.0],
		"platform_color": Color(0.25, 0.44, 0.20),
		"modifiers": {
			"speed_mult":   1.0,
			"jump_mult":    1.0,
			"gravity_mult": 1.0,
			"friction":     0.08,
			"air_control":  0.70,
		},
		"platforms": [
			[0,    620, 200, 28],
			[380,  620, 100, 28],
			[660,  620, 100, 28],
			[940,  620, 100, 28],   # CHECKPOINT
			[1220, 620, 200, 28],
			#[1320, 540, 100, 18],
			[1500, 620, 360, 28],
		],
		"breakable_blocks": [
			[1250, 570,  140, 50]
		],
		"switches": [
			[1, 1300, 612, 40, 8, true],
		],
		"gates": [
			[1, 1500, 320, 22, 300],
		],
		"stars": [
			[150, 450],   
			[1320, 400],   
			[850, 500],  
			#[280, 440],   
		],
		"exit_pos":    [1750, 570],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [150,  560],
		"loopy_start": [1580, 572],
		"loopy_end":   [1730, 572],
	}
