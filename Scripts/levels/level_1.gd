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
			[0,    620, 360, 28],
			[440,  540, 130, 18],
			[650,  460, 100, 18],
			[820,  540, 140, 18],
			[1030, 460, 110, 18],
			[1210, 555, 200, 22],   # checkpoint
			[1490, 465, 120, 18],
			[1680, 375, 110, 18],
			[1860, 460, 110, 18],
			[2050, 545, 140, 18],
			[2260, 460, 100, 18],
			[2430, 555, 160, 18],
			[2620, 620, 420, 28],
		],

		"checkpoints": [
			[1260, 530],
		],
		"hazards": [
			[ 380, 600,  50, 22],   # gap inicial
			[ 770, 510,  40, 22],   # gap entre plataformas baixas
			[1160, 540,  40, 22],   # antes do checkpoint
			[1820, 440,  30, 22],   # após plataforma alta
			[2380, 530,  40, 22],   # antes do salto final
		],
		"pushable_blocks": [
			[200, 580, 40, 40],
		],
		"stars": [
			[970, 400],   # Sobre o gap, requer pulo preciso entre plataformas
			[1705, 290],  # Bem acima da plataforma alta — exige pulo no limite
			[2370, 410],  # No gap antes da saída
			[300, 460],   # Estrela do Bog — empurre o bloco para baixo dela
		],
		"exit_pos":    [2940, 580],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [160,  560],
		"loopy_start": [2780, 572],
		"loopy_end":   [3200, 572],
	}
