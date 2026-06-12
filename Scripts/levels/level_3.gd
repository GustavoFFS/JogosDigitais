extends RefCounted
class_name Level3Data

## Fase 3 - Fábrica Abandonada
## Ajustes de acessibilidade: plataformas mais baixas e hazards reposicionados.

static func get_data() -> Dictionary:
	return {
		"name": "Fábrica Abandonada",
		"description": "Loopy entrou nos portões de metal da velha fábrica...\nAlterne de personagem e destranque as passagens!",
		"modifier_hint": "Portas e Botões  ·  Empurre a caixa sobre o botão!",
		"ambient_type": "factory",
		"dialogues": [
			{"speaker": "Rob", "text": "Tem portões trancados aqui..."},
			{"speaker": "Bog", "text": "Deixa comigo, vou empurrar a caixa!"},
		],
		"bg_color":       Color(0.742, 0.81, 0.794, 1.0),
		"bg_image": "res://Assets/Backgrounds/FabricaAbandonada.png",
		"dust_effect":    true,
		"bg_size": [8000.0, 1080.0],
		"platform_color": Color(0.65, 0.35, 0.20),
		"modifiers": {
			"speed_mult":   1.0,
			"jump_mult":    1.0,
			"gravity_mult": 1.0,
			"friction":     1.0,
			"air_control":  1.0,
		},
		"platforms": [
			[0,    620, 280, 28],
			[360,  560, 120, 18],   # Mais baixo (era 520)
			[560,  480, 110, 18],   # Mais baixo (era 420)
			[760,  530, 120, 18],   # Mais baixo (era 520)
			[970,  460, 100, 18],   # Mais baixo (era 420)
			[1150, 560, 210, 22],   # CHECKPOINT (era 545)
			[1440, 500, 120, 18],   # Mais baixo (era 440)
			[1640, 420, 110, 18],   # Mais baixo (era 340)
			[1840, 500, 120, 18],   # Mais baixo (era 440)
			[2040, 560, 120, 18],   # Mais baixo (era 545)
			[2230, 620, 360, 28],
		],
		"checkpoints": [
			[1210, 535],
		],
		"hazards": [
			[ 300, 600,  50, 22],   # Mais baixo
			[ 480, 540,  60, 22],   # Reajustado
			[ 880, 590,  70, 22],
			[1370, 590,  60, 22],
			[1750, 530,  70, 22],   # Reajustado
			[2150, 580,  60, 22],   # Reajustado
		],
		"pushable_blocks": [
			[140, 580, 40, 40],
		],
		"switches": [
			[1, 230, 612, 40, 8],
		],
		"gates": [
			[1, 410, 450, 16, 110],  # Reajustado para a nova altura de plat 2
		],
		"stars": [
			[420, 430],   # Rebaixado (era 385)
			[1690, 310],  # Rebaixado (era 220)
			[2125, 470],  # Rebaixado (era 415)
			[220, 440],   # Estrela do Bog (era 410)
		],
		"exit_pos":    [2510, 572],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [100,  560],
		"loopy_start": [2360, 572],
		"loopy_end":   [2510, 572],
	}
