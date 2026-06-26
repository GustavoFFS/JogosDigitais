extends RefCounted
class_name Level6Data

## Fase 6 - Esgotos de Loop
## Introduz Crumbling Platforms (plataformas instáveis que caem).

static func get_data() -> Dictionary:
	return {
		"name": "Esgotos de Loop",
		"description": "Descendo pelos canos... a água escorre sob blocos instáveis.\nCorra antes que tudo desmorone!",
		"modifier_hint": "Plataformas Instáveis  ·  Não fique parado!",
		"ambient_type": "sewer",
		"dialogues": [
			{"speaker": "Rob", "text": "Ugh, que cheiro..."},
			{"speaker": "Bog", "text": "O chão tá cedendo! Corre!"},
		],
		"bg_color":       Color(0.05, 0.08, 0.06),
		"bg_image": "res://Assets/Backgrounds/Esgoto.png",
		"insect_effect":  true,
		"bg_size": [8000.0, 1080.0],
		"platform_color": Color(0.20, 0.36, 0.24),
		"modifiers": {
			"speed_mult":   1.0,
			"jump_mult":    1.0,
			"gravity_mult": 1.0,
			"friction":     1.0,
			"air_control":  1.0,
		},
		"platforms": [
			[0,    620, 240, 28],
			[640,  560, 200, 22],   # Checkpoint
			[1000,  480, 140, 18],
			[2200, 620, 100, 18],
			[3400, 620, 360, 28],   # Final
		],
		"moving_platforms": [
			{
				"start_pos": Vector2(2500.0, 660.0),
				"end_pos":   Vector2(2500.0, 420.0),
				"w": 100.0,
				"h": 18.0,
				"speed": 100.0,
				"to_end": true
			},
			{
				"start_pos": Vector2(2850.0, 660.0),
				"end_pos":   Vector2(2850.0, 420.0),
				"w": 100.0,
				"h": 18.0,
				"speed": 130.0,
				"to_end": true
			},
			{
				"start_pos": Vector2(3200.0, 660.0),
				"end_pos":   Vector2(3200.0, 420.0),
				"w": 100.0,
				"h": 18.0,
				"speed": 160.0,
				"to_end": true
			},
			
		],
		"crumbling_platforms": [
			[280, 530, 80, 18],
			[400, 460, 80, 18],
			[520, 530, 80, 18],
		],
		"checkpoints": [
			[740, 535],
			[2250, 590],
		],
		"hazards": [
			[ 240, 590, 400, 22],
			[ 1000, 650,  2400, 22],
			#[ 2300, 650, 1460, 22],
		],
		"pushable_blocks": [
			#[80, 580, 40, 40],
		],
		"levers": [
			[1, 800, 520, 40, 40],
		],
		"speed_pads": [
			[1300, 400, 40, 20, 2.0],
			[1600, 420, 40, 20, 2.0],
			[1900, 440, 40, 20, 2.0],
		],
		"gates": [
			[1, 1000, 350, 20, 130],
		],
		"stars": [
			#[440, 380],   # Acima do percurso instável
			[1070, 310],  # Alto
			#[1210, 400],  # No pulo para o final
			[160, 460],   # Estrela do Bog
		],
		"exit_pos":    [3680, 570],
		"spawn_rob":   [40,   560],
		"spawn_bog":   [130,  560],
		"loopy_start": [3500, 572],
		"loopy_end":   [3660, 572],
	}
