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
			[0,    620, 360, 28],   # Plataforma inicial
			[440,  540, 130, 18],   # Primeiro salto
			[650,  460, 100, 18],   # Subida
			[820,  540, 140, 18],   # Descida suave
			[1030, 460, 110, 18],   # Salto sobre vazio
			[1210, 555, 200, 22],   # Plataforma larga (checkpoint)
			[1490, 465, 120, 18],   # Subida
			[1680, 375, 110, 18],   # Plataforma alta
			[1860, 460, 110, 18],   # Descida
			[2050, 545, 140, 18],   # Penúltimo
			[2260, 460, 100, 18],   # Salto curto
			[2430, 555, 160, 18],   # Perto da saída
			[2620, 620, 420, 28],   # Plataforma final
		],

		# [x, y] - topo da bandeira
		"checkpoints": [
			[1260, 530],
		],
		# [x, y, largura, altura] - zonas de espinhos
		"hazards": [
			[930, 590, 80, 22],
			[2180, 530, 60, 22],
		],
		"exit_pos":    [2940, 580],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [160,  560],
		"loopy_start": [2780, 572],
		"loopy_end":   [3200, 572],
	}
