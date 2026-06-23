extends RefCounted
class_name Level10Data

## Fase 10 - Encontro Final no Loop
## Desafio Supremo: Cooperação de gravidade, blocos flutuantes e botões pesados.

static func get_data() -> Dictionary:
	return {
		"name": "Encontro Final no Loop",
		"description": "Ali está o Loopy! Ele parou em frente ao Café Loop...\nUse toda a sua habilidade e coordenação para resgatar seu amigo!",
		"modifier_hint": "Desafio Supremo Final  ·  Combine todas as forças!",
		"ambient_type": "epic_tension",
		"dialogues": [
			{"speaker": "Rob", "text": "Ali! Eu vejo o Loopy!"},
			{"speaker": "Bog", "text": "Última fase... vamos dar tudo!"},
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
			[1200, 180, 80, 10],    # Teto sólido do botão 3 (Gravity Lift)
			[1380, 300, 180, 18],   # Plataforma superior com botão pesado
			[1540, 620, 510, 28],   # Final
		],
		"crumbling_platforms": [
			[500,  450, 80, 18],
			[1280, 320, 80, 18],   # Rota superior (entre caixa flutuante e plat botão pesado)
			[1360, 530, 80, 18],   # Rota inferior (ponte instável nos espinhos)
		],
		"speed_pads": [
			[660, 510, 40, 20, 1.0],
		],
		"jump_pads": [
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
		],
		"checkpoints": [
			[1080, 535],
		],
		"hazards": [
			[ 240,  590, 100, 22],
			[ 450,  590, 170, 22],
			[ 740,  590, 240, 22],
			[ 1180, 590, 360, 22],   # Fosso de espinhos final
		],
		"stars": [
			[390,  420],
			[700,  260],
			[1220, 150],  # Estrela alta sobre o Gravity Lift (exige usar a caixa como degrau ou dash)
			[220,  420],  # Estrela do Bog
		],
		"exit_pos":    [1950, 590],
		"spawn_rob":   [40,   560],
		"spawn_bog":   [90,   560],
		"loopy_start": [1800, 572],
		"loopy_end":   [1930, 572],
	}
