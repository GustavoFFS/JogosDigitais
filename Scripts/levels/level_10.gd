extends RefCounted
class_name Level10Data

## Fase 10 - Encontro Final no Loop
## Desafio Supremo: Cooperação de gravidade, blocos flutuantes e botões pesados.

static func get_data() -> Dictionary:
	return {
		"name": "Encontro Final no Loop",
		"description": "Ali está o Loopy! Ele parou na frente daquele portal gigantesco...\nUse toda a sua habilidade e coordenação para resgatar seu amigo!",
		"modifier_hint": "Desafio Final  ·  Chegue em Loopy!",
		"ambient_type": "epic_tension",
		"dialogues": [
			{"speaker": "Rob", "text": "Ali! Eu vejo o Loopy. Ele parece cansado."},
			{"speaker": "Bog", "text": "Estamos chegando... vamos com tudo!"},
		],
		"bg_color":       Color(0.742, 0.81, 0.794, 1.0),
		"bg_image": "res://Assets/Backgrounds/EncontroFinal.png",
		"bg_size": [8000.0, 1080.0],
		"platform_color": Color(0.48, 0.20, 0.65),
		"modifiers": {
			"speed_mult":   1.15,
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
			[1380, 330, 180, 18],   # Plataforma superior com botão pesado
			[1740, 620, 1010, 28],   # Final
		],
		"crumbling_platforms": [
			[500,  450, 80, 18],
			[1280, 420, 80, 18],   # Rota superior (entre caixa flutuante e plat botão pesado)
		],
		"speed_pads": [
			[660, 510, 40, 20, 1.0],
			[1000, 540, 40, 20, -1.0],
		],
		"jump_pads": [
			[1120, 540, 30, 20],   # Lança o jogador até a caixa flutuante
		],
		"switches": [
			[4, 1450, 322, 40, 8],  # Botão pesado na rota superior (ativado apenas por Bog)
		],
		"gates": [
			[4, 2380, 420, 16, 200],  # Portão 4 (rota final - abre com botão pesado 4)
		],

		"hazards": [
			[ 240, 620, 1500, 28],   # Fosso de espinhos final
		],
		"stars": [
			[390,  320],
			[700,  260],
			[1220, 150],  
			[2523,  480],  
		],
		"exit_pos":    [2650, 580],
		"spawn_rob":   [40,   560],
		"spawn_bog":   [90,   560],
		"loopy_start": [2500, 572],
		"loopy_end":   [2630, 572],
	}
