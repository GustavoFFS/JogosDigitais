extends RefCounted
class_name Level1Data

## Fase 1 - Ruas da Cidade
## Controles normais. Tutorial com obstaculos moderados.

static func get_data() -> Dictionary:
	return {
		"name": "Ruas da Cidade",
		"description": "Rob e Bog viram Loopy sair do Café Loop com olhar distante...\na busca começa aqui nas ruas!",
		"modifier_hint": "Controles Normais  ·  Aprenda o básico!",
		"bg_color":       Color(0.13, 0.16, 0.26),
		"platform_color": Color(0.38, 0.40, 0.45),
		"modifiers": {
			"speed_mult":   1.0,
			"jump_mult":    1.0,
			"gravity_mult": 1.0,
			"friction":     1.0,
			"air_control":  1.0,
		},
		# [x, y, largura, altura]
		"platforms": [
			[0,    620, 320, 28],   # Plataforma inicial (mais curta)
			[440,  540, 100, 18],
			[640,  450,  80, 18],
			[810,  540, 110, 18],
			[1010, 450,  90, 18],
			[1190, 555, 180, 22],   # checkpoint
			[1470, 460, 100, 18],
			[1660, 365,  90, 18],
			[1840, 455,  90, 18],
			[2030, 545, 120, 18],
			[2240, 455,  80, 18],
			[2410, 555, 130, 18],
			[2620, 620, 420, 28],   # Plataforma final
		],

		"checkpoints": [
			[1240, 530],
		],
		"hazards": [
			[ 540, 590, 100, 22],
			[ 720, 590, 100, 22],
			[ 920, 590, 100, 22],
			[1120, 590, 100, 22],
			[2150, 530,  90, 22],
			[2540, 590,  90, 22],
		],
		"pushable_blocks": [
			[200, 580, 40, 40],
		],
		"stars": [
			[700, 430],
			[1730, 345],
			[2290, 430],
			[300, 460],   # Estrela do Bog — empurre o bloco para baixo dela
		],
		"exit_pos":    [2940, 580],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [160,  560],
		"loopy_start": [2780, 572],
		"loopy_end":   [3200, 572],
	}
