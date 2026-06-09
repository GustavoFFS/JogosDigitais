extends RefCounted
class_name Level10Data

## Fase 10 - Encontro Final no Loop
## Ajustes de acessibilidade: plataformas instáveis mais baixas e salto final encurtado.

static func get_data() -> Dictionary:
	return {
		"name": "Encontro Final no Loop",
		"description": "Ali está o Loopy! Ele parou em frente ao Café Loop...\nUse toda a sua habilidade e coordenação para resgatar seu amigo!",
		"modifier_hint": "Desafio Supremo Final  ·  Combine todas as forças!",
		"bg_color":       Color(0.22, 0.11, 0.14),
		"bg_image": "res://Assets/Backgrounds/EncontroFinal.png",
		"bg_size": [8000.0, 1080.0],
		"platform_color": Color(0.48, 0.20, 0.65),
		"modifiers": {
			"speed_mult":   1.20,
			"jump_mult":    1.20,
			"gravity_mult": 1.20,
			"friction":     0.18,
			"air_control":  0.65,
		},
		"platforms": [
			[0,    620, 240, 28],
			[340,  530, 110, 18],
			[620,  530, 120, 18],
			[820,  450, 100, 18],
			[980,  560, 200, 22],   # CHECKPOINT
			[1540, 620, 510, 28],   # Final (estendido para a esquerda de 1600 para 1540)
		],
		"crumbling_platforms": [
			[500,  450, 80, 18],
			[1200, 460, 80, 18],   # Mais baixo e próximo (era 1220/380)
			[1340, 460, 80, 18],   # Mais baixo (era 1360/380)
		],
		"speed_pads": [
			[660, 510, 40, 20, 1.0],
		],
		"jump_pads": [
			[1120, 540, 30, 20],
		],
		"pushable_blocks": [
			[120, 580, 40, 40],
		],
		"switches": [
			[1, 180,  612, 40, 8],
			[2, 1360, 452, 40, 8], # Botão em cima da plataforma que cai (reajustado para y=452)
		],
		"gates": [
			[1, 280,  430, 16, 110],
			[2, 1480, 340, 16, 130], # Portão 2 (reajustado para y=340)
		],
		"checkpoints": [
			[1080, 535],
		],
		"hazards": [
			[ 240,  590, 100, 22],
			[ 450,  590, 170, 22],
			[ 740,  590, 240, 22],
			[ 1180, 590, 360, 22],   # Reduzido comprimento do espinho final
		],
		"stars": [
			[390,  420],
			[700,  260],
			[1240, 320],  # Rebaixada (era 240)
			[220,  420],  # Estrela do Bog
		],
		"exit_pos":    [1950, 590],
		"spawn_rob":   [40,   560],
		"spawn_bog":   [110,  560],
		"loopy_start": [1800, 572],
		"loopy_end":   [1930, 572],
	}
