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
		],
		"bg_color":       Color(0.09, 0.06, 0.12),
		"bg_image": "res://Assets/Backgrounds/EstacaoMetro.png",
		"bg_size": [8000.0, 1080.0],
		"platform_color": Color(0.36, 0.38, 0.44),
		"modifiers": {
			"speed_mult":   1.05,
			"jump_mult":    1.0,
			"gravity_mult": 1.05,
			"friction":     0.85,
			"air_control":  0.80,
		},

		# ========================================================
		# PLATAFORMAS SÓLIDAS (10 plataformas)
		# ========================================================
		"platforms": [
			# --- ZONA A: Trilhos Elétricos ---
			[0,    620, 280, 28],       # Plataforma inicial (spawn)
			[440,  570, 160, 22],       # Plataforma do botão 1
			[700,  480, 130, 18],       # Plataforma elevada pré-portão

			# --- ZONA B: Câmara de Gravidade ---
			[900,  560, 220, 22],       # Plataforma pós-portão 1 (CHECKPOINT 1)
			[1240, 480, 120, 18],       # Plataforma intermediária
			[1440, 360, 140, 18],       # Plataforma suspensa (botão pesado)
			[1440, 160, 140, 10],       # Teto sólido da zona de gravidade (impede fuga)
			[1660, 560, 200, 22],       # Plataforma pós-portão 2 (CHECKPOINT 2)

			# --- ZONA C: Túnel de Fuga ---
			[2060, 500, 160, 18],       # Plataforma após speed pad
			[2520, 620, 380, 28],       # Plataforma final (saída)
		],

		# ========================================================
		# PLATAFORMAS INSTÁVEIS (crumbling) — 5 plataformas
		# ========================================================
		"crumbling_platforms": [
			# Zona A — sobre os trilhos elétricos (espinhos)
			[300,  530, 110, 18],       # Ponte instável 1
			[180,  460, 100, 18],       # Ponte instável 2 (acesso estrela alta)

			# Zona B — ponte instável sobre fosso
			[1130, 520, 100, 18],       # Atalho para plataforma intermediária

			# Zona C — antes da saída
			[2300, 540, 100, 18],       # Ponte instável pré-saída 1
			[2420, 480, 90,  18],       # Ponte instável pré-saída 2
		],

		# ========================================================
		# PLATAFORMAS MÓVEIS — 2 plataformas
		# ========================================================
		"moving_platforms": [
			# Zona B — elevador vertical para acessar estrela alta
			{
				"start_pos": Vector2(1180.0, 500.0),
				"end_pos":   Vector2(1180.0, 320.0),
				"w": 80.0,
				"h": 18.0,
				"speed": 90.0,
				"to_end": true
			},
			# Zona C — plataforma horizontal sobre o fosso final
			{
				"start_pos": Vector2(2230.0, 440.0),
				"end_pos":   Vector2(2380.0, 440.0),
				"w": 90.0,
				"h": 18.0,
				"speed": 110.0,
				"to_end": true
			},
		],

		# ========================================================
		# BLOCOS EMPURRÁVEIS (Bog only) — 2 blocos
		# ========================================================
		"pushable_blocks": [
			[160,  580, 40, 40],        # Zona A — empurrar até o botão 1
			[960,  520, 40, 40],        # Zona B — levitar pela zona de gravidade
		],

		# ========================================================
		# BOTÕES (switches) — 3 botões
		# ========================================================
		"switches": [
			# [id, x, y, w, h, is_heavy?]
			[1, 480, 532, 40, 8],             # Zona A — botão 1 (regular, abre portão 1)
			[2, 1480, 352, 40, 8, true],      # Zona B — botão 2 (HEAVY, abre portão 2)
			[3, 2120, 492, 40, 8],            # Zona C — botão 3 (regular, abre portão 3)
		],

		# ========================================================
		# PORTÕES (gates) — 3 portões
		# ========================================================
		"gates": [
			# [switch_id, x, y, w, h]
			[1, 830,  380, 16, 100],    # Portão 1 — bloqueia entrada da Zona B
			[2, 1600, 420, 16, 140],    # Portão 2 — bloqueia saída da Zona B
			[3, 2460, 500, 16, 120],    # Portão 3 — bloqueia acesso à saída final
		],

		# ========================================================
		# ZONA DE GRAVIDADE — 1 zona
		# ========================================================
		"gravity_zones": [
			[1380, 180, 100, 340],      # Zona B — eleva bloco/personagem até o botão pesado
		],

		# ========================================================
		# JUMP PADS (molas) — 2 pads
		# ========================================================
		"jump_pads": [
			[640, 440, 30, 20],         # Zona A — lança para plataforma elevada
			[1100, 540, 30, 20],        # Zona B — lança para zona de gravidade
		],

		# ========================================================
		# SPEED PADS (aceleradores) — 1 pad
		# ========================================================
		"speed_pads": [
			[1950, 440, 40, 20, 1.0],   # Zona C — impulso horizontal para cruzar o gap
		],

		# ========================================================
		# BLOCOS QUEBRÁVEIS (Bog ground pound) — 2 blocos
		# ========================================================
		"breakable_blocks": [
			[2080, 440, 40, 60],        # Zona C — esconde caminho para o botão 3
			[2140, 440, 40, 60],        # Zona C — segundo bloco quebrável (parede)
		],

		# ========================================================
		# CHECKPOINTS — 2 bandeiras
		# ========================================================
		"checkpoints": [
			[1000, 535],                # Checkpoint 1 — início da Zona B
			[1740, 535],                # Checkpoint 2 — início da Zona C
		],

		# ========================================================
		# HAZARDS (espinhos) — 5 zonas de morte
		# ========================================================
		"hazards": [
			[280,  590, 160, 22],       # Zona A — fosso sob plataformas instáveis
			[600,  590, 100, 22],       # Zona A — fosso pré jump pad
			[1050, 590, 260, 22],       # Zona B — grande fosso central
			[1380, 590, 220, 22],       # Zona B — fosso sob a zona de gravidade
			[1880, 590, 380, 22],       # Zona C — grande fosso do túnel de fuga
		],

		# ========================================================
		# ESTRELAS — 4 coletáveis
		# ========================================================
		"stars": [
			[220,  380],                # ★1 — Zona A: acima das crumbling (exige pulo preciso)
			[1200, 240],                # ★2 — Zona B: alta, acessível pela plataforma móvel
			[2160, 360],                # ★3 — Zona C: atrás dos blocos quebráveis (precisa Bog)
			[500,  440],                # ★4 — Estrela do Bog: perto do botão 1
		],

		# ========================================================
		# POSIÇÕES DE SPAWN E SAÍDA
		# ========================================================
		"exit_pos":    [2800, 580],
		"spawn_rob":   [50,   560],
		"spawn_bog":   [130,  560],
		"loopy_start": [2640, 572],
		"loopy_end":   [2780, 572],
	}
