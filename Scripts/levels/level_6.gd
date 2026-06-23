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
			[640,  560, 200, 22],   # CHECKPOINT
			[880,  480, 100, 18],
			[1020, 390, 100, 18],
			[1160, 480, 100, 18],
			[1300, 620, 360, 28],
		],
		"crumbling_platforms": [
			[280, 530, 80, 18],
			[400, 460, 80, 18],
			[520, 530, 80, 18],
		],
		"checkpoints": [
			[740, 535],
		],
		"hazards": [
			[ 240, 590, 400, 22],
			[ 980, 530,  40, 22],
			[1260, 590,  40, 22],
		],
		"pushable_blocks": [
			[80, 580, 40, 40],
		],
		"levers": [
			[1, 800, 540, 40, 40],
		],
		"gates": [
			[1, 880, 410, 20, 70],
		],
		"stars": [
			[440, 380],   # Acima do percurso instável
			[1070, 310],  # Alto
			[1210, 400],  # No pulo para o final
			[160, 460],   # Estrela do Bog
		],
		"exit_pos":    [1580, 570],
		"spawn_rob":   [40,   560],
		"spawn_bog":   [130,  560],
		"loopy_start": [1400, 572],
		"loopy_end":   [1560, 572],
	}
