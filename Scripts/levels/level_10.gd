extends RefCounted
class_name Level10Data

## Fase 10 - Encontro Final no Loop
<<<<<<< HEAD
## Desafio Supremo: Cooperação de gravidade, blocos flutuantes e botões pesados.
=======
## Ajustes de acessibilidade: plataformas instáveis mais baixas e salto final encurtado.
>>>>>>> 95a70239ae1677ac88b33fb622bcd3768c4c8119

static func get_data() -> Dictionary:
	return {
		"name": "Encontro Final no Loop",
		"description": "Ali está o Loopy! Ele parou em frente ao Café Loop...\nUse toda a sua habilidade e coordenação para resgatar seu amigo!",
		"modifier_hint": "Desafio Supremo Final  ·  Combine todas as forças!",
<<<<<<< HEAD
		"ambient_type": "epic_tension",
		"dialogues": [
			{"speaker": "Rob", "text": "Ali! Eu vejo o Loopy!"},
			{"speaker": "Bog", "text": "Última fase... vamos dar tudo!"},
		],
=======
>>>>>>> 95a70239ae1677ac88b33fb622bcd3768c4c8119
		"bg_color":       Color(0.22, 0.11, 0.14),
		"bg_image": "res://Assets/Backgrounds/EncontroFinal.png",
		"bg_size": [8000.0, 1080.0],
		"platform_color": Color(0.48, 0.20, 0.65),
		"modifiers": {
<<<<<<< HEAD
			"speed_mult":   1.15,
=======
			"speed_mult":   1.20,
>>>>>>> 95a70239ae1677ac88b33fb622bcd3768c4c8119
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
<<<<<<< HEAD
			[1200, 180, 80, 10],    # Teto sólido do botão 3 (Gravity Lift)
			[1380, 300, 180, 18],   # Plataforma superior com botão pesado
			[1540, 620, 510, 28],   # Final
		],
		"crumbling_platforms": [
			[500,  450, 80, 18],
			[1280, 320, 80, 18],   # Rota superior (entre caixa flutuante e plat botão pesado)
			[1360, 530, 80, 18],   # Rota inferior (ponte instável nos espinhos)
=======
			[1540, 620, 510, 28],   # Final (estendido para a esquerda de 1600 para 1540)
		],
		"crumbling_platforms": [
			[500,  450, 80, 18],
			[1200, 460, 80, 18],   # Mais baixo e próximo (era 1220/380)
			[1340, 460, 80, 18],   # Mais baixo (era 1360/380)
>>>>>>> 95a70239ae1677ac88b33fb622bcd3768c4c8119
		],
		"speed_pads": [
			[660, 510, 40, 20, 1.0],
		],
		"jump_pads": [
<<<<<<< HEAD
			[1120, 540, 30, 20],   # Lança o jogador até a caixa flutuante
		],
		"pushable_blocks": [
			[120,  580, 40, 40],   # Caixa 1 (para o botão 1)
			[1000, 520, 40, 40],   # Caixa 2 (para levitar e ativar botão 3)
		],
		"switches": [
			[1, 180,  612, 40, 8],
			[3, 1220, 185, 40, 8],        # Botão suspenso no teto da gravidade (ativado pela caixa flutuante)
			[4, 1450, 292, 40, 8, true],  # Botão pesado na rota superior (ativado apenas por Bog)
		],
		"gates": [
			[1, 280,  430, 16, 110],  # Portão 1
			[3, 1340, 200, 16, 100],  # Portão 3 (rota superior - abre com botão 3)
			[4, 1680, 470, 16, 150],  # Portão 4 (rota final - abre com botão pesado 4)
		],
		"gravity_zones": [
			[1200, 220, 80, 360],   # Elevador antigravidade para a Caixa 2
=======
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
>>>>>>> 95a70239ae1677ac88b33fb622bcd3768c4c8119
		],
		"checkpoints": [
			[1080, 535],
		],
		"hazards": [
			[ 240,  590, 100, 22],
			[ 450,  590, 170, 22],
			[ 740,  590, 240, 22],
<<<<<<< HEAD
			[ 1180, 590, 360, 22],   # Fosso de espinhos final
=======
			[ 1180, 590, 360, 22],   # Reduzido comprimento do espinho final
>>>>>>> 95a70239ae1677ac88b33fb622bcd3768c4c8119
		],
		"stars": [
			[390,  420],
			[700,  260],
<<<<<<< HEAD
			[1220, 150],  # Estrela alta sobre o Gravity Lift (exige usar a caixa como degrau ou dash)
=======
			[1240, 320],  # Rebaixada (era 240)
>>>>>>> 95a70239ae1677ac88b33fb622bcd3768c4c8119
			[220,  420],  # Estrela do Bog
		],
		"exit_pos":    [1950, 590],
		"spawn_rob":   [40,   560],
<<<<<<< HEAD
		"spawn_bog":   [90,   560],
=======
		"spawn_bog":   [110,  560],
>>>>>>> 95a70239ae1677ac88b33fb622bcd3768c4c8119
		"loopy_start": [1800, 572],
		"loopy_end":   [1930, 572],
	}
