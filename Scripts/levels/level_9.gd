extends RefCounted
class_name Level9Data

## Fase 9 - Estação de Metrô
## Ajustes de acessibilidade: plataformas instáveis mais largas para facilitar pouso pós-boost.

static func get_data() -> Dictionary:
	return {
		"name": "Estação de Metrô",
		"description": "Os túneis escuros do metrô ocultam trilhos de alta velocidade!\nUse os aceleradores para voar através das plataformas instáveis!",
		"modifier_hint": "Aceleradores  +  Plataformas Instáveis",
		"bg_color":       Color(0.11, 0.08, 0.14),
		"bg_image": "res://Assets/Backgrounds/EstacaoMetro.png",
		"bg_size": [8000.0, 1080.0],
		"platform_color": Color(0.40, 0.42, 0.46),
		"modifiers": {
			"speed_mult":   1.0,
			"jump_mult":    1.0,
			"gravity_mult": 1.0,
			"friction":     1.0,
			"air_control":  1.0,
		},
		"platforms": [
			[0,    620, 240, 28],
			[800,  560, 200, 22],   # CHECKPOINT (deslocado para 800)
			[1180, 620, 360, 28],   # Ajustado final
		],
		"crumbling_platforms": [
			[300,  530, 110, 18],   # Mais larga (era 320/90)
			[470,  450, 110, 18],   # Mais larga (era 470/90)
			[640,  520, 110, 18],   # Mais larga (era 620/90)
		],
		"jump_pads": [
			[940, 540, 30, 20],
		],
		"pushable_blocks": [
			[820, 520, 40, 40],
		],
		"switches": [
			[1, 880, 552, 40, 8, true],
		],
		"breakable_blocks": [
			[1240, 560, 40, 60],
		],
		"gates": [
			[1, 1100, 380, 16, 100],
		],
		"checkpoints": [
			[900, 535],
		],
		"hazards": [
			[ 240, 590, 560, 22],
			[ 1000, 590, 180, 22],
		],
		"stars": [
			[505, 310],   # Ajustado
			[940, 260],
			[1130, 420],
			[200, 440],   # Estrela do Bog
		],
		"exit_pos":    [1440, 570],
		"spawn_rob":   [50,   560],
		"spawn_bog":   [130,  560],
		"loopy_start": [1280, 572],
		"loopy_end":   [1420, 572],
	}
