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
			{"speaker": "Bog", "text": "Pelo menos tem botões pra ajudar."},
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
			[0,    620, 360, 28],
			[460,  520, 130, 18],
			[650,  440, 120, 18],
			[850,  545, 200, 22],   # CHECKPOINT
			[1120, 460, 120, 18],
			[1320, 540, 100, 18],
			[1500, 620, 360, 28],
		],
		"pushable_blocks": [
			[220, 580, 40, 40],
		],
		"switches": [
			[1, 300, 612, 40, 8],
		],
		"gates": [
			[1, 520, 420, 16, 100],
		],
		"checkpoints": [
			[950, 520],
		],
		"hazards": [
			[ 360, 590, 100, 22],
			[ 770, 590,  80, 22],
			[1050, 590, 450, 22],
		],
		"stars": [
			[520, 340],   # Acima do portão de energia
			[710, 320],   # Pulo alto
			[1220, 380],  # No gap escorregadio
			[280, 440],   # Estrela do Bog
		],
		"exit_pos":    [1750, 570],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [150,  560],
		"loopy_start": [1580, 572],
		"loopy_end":   [1730, 572],
	}
