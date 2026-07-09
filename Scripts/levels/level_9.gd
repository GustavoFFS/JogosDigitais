extends RefCounted
class_name Level9Data

## Fase 9 - Estação de Metrô — "Labirinto Subterrâneo"
## Puzzle avançado com 3 zonas interconectadas:
##   Zona A (0-800)   — Trilhos Elétricos: empurrar bloco + plataformas instáveis
##   Zona B (800-1800) — Câmara de Gravidade: gravity zone + botão pesado + plataforma móvel
##   Zona C (1800-2800) — Túnel de Fuga: speed pad + blocos quebráveis + portão final

static func get_data() -> Dictionary:
	return {
		"name": "Estação de Metrô",
		"description": "O labirinto subterrâneo do metrô esconde perigos em cada túnel...\nAlterne Rob e Bog para resolver os puzzles de cada câmara!",
		"modifier_hint": "Puzzle Avançado  ·  Cooperação Total!",
		"ambient_type": "metro",
		"dialogues": [
			{"speaker": "Rob", "text": "Esse metrô é um labirinto..."},
			{"speaker": "Bog", "text": "Vamos ter que trabalhar juntos nessa."},
			{"speaker": "Bog", "text": "Lembre-se da nossa jornada. Não vamos desistir."},
		],
		"bg_color":       Color(0.09, 0.06, 0.12),
		"bg_image": "res://Assets/Backgrounds/EstacaoMetro.png",
		"bg_size": [8000.0, 1080.0],
		"platform_color": Color(0.36, 0.38, 0.44),
		"modifiers": {
			"speed_mult":   1.05,
			"jump_mult":    1.0,
			"gravity_mult": 1.05,
			"friction":     0.10,
			"air_control":  0.80,
		},

		# ========================================================
		# PLATAFORMAS SÓLIDAS (10 plataformas)
		# ========================================================
		"platforms": [
			[0,    620, 280, 28],       # Plataforma inicial (spawn)
			[440,  570, 160, 22],       # Plataforma do botão 1
			[900,  560, 220, 22],       # Plataforma (Com fricção?)
			[1360, 160, 140, 22],       # Teto sólido da zona de gravidade (impede fuga)
			[1660, 560, 200, 22],       # Plataforma pós-portão 2 (CHECKPOINT 2)
			[2520, 620, 380, 28],       # Plataforma final (saída)
		],

		"crumbling_platforms": [
			[300,  530, 110, 18],       # Ponte instável 1
			[180,  460, 100, 18],       # Ponte instável 2 (acesso estrela alta)

			[2300, 580, 100, 18],       # Ponte instável pré-saída 1
		],

		"pushable_blocks": [
			[95,  580, 40, 40],        # Zona A — empurrar até o botão 1
		],

		"switches": [
			[3, 1410, 175, 40, 8],            # Zona C — botão 3 (regular, abre portão 3)
		],

		"gates": [
			[3, 2520, 320, 16, 300],    # Portão 3 — bloqueia acesso à saída final
		],

		"gravity_zones": [
			[1380, 180, 100, 300],      # Zona B — eleva bloco/personagem até o botão pesado
		],

		"jump_pads": [
			[570, 550, 30, 20],         # Zona A — lança para plataforma elevada
		],

		"speed_pads": [
			[1950, 440, 40, 20, 1.0],   # Zona C — impulso horizontal para cruzar o gap
		],

		"stars": [
			[220,  300],
			[580,  350],
			[1200, 240],
		],
		"hints":[
			[140, 400, "Esse nível é mais difícil. \nUse tudo o que você aprendeu."]	
		],

		"exit_pos":    [2800, 580],
		"spawn_rob":   [180,   560],
		"spawn_bog":   [50,  560],
		"loopy_start": [2640, 572],
		"loopy_end":   [2780, 572],
	}
