extends RefCounted
class_name Level2Data

## Fase 2 - Praça Escorregadia
## Friccao muito baixa. Loopy foi avistado deslizando pela praca.

static func get_data() -> Dictionary:
	return {
		"name": "Praça Escorregadia",
		"description": "Loopy foi avistado deslizando pela praça...\no chão gelado dificulta cada passo!",
		"modifier_hint": "Baixa Fricção  ·  Cuidado com o deslize!",
		"bg_color":       Color(0.10, 0.18, 0.30),
		"platform_color": Color(0.52, 0.78, 0.88),
		"modifiers": {
			"speed_mult":   1.0,
			"jump_mult":    1.0,
			"gravity_mult": 1.0,
			"friction":     0.12,
			"air_control":  0.80,
		},
		"platforms": [
			[0,    620, 320, 28],   # Início
			[400,  550, 130, 18],   # Primeiro gap (gelo dificulta parar)
			[600,  465, 90,  18],   # Plataforma estreita
			[760,  545, 160, 18],   # Mais larga
			[990,  455, 100, 18],   # Salto
			[1160, 560, 220, 22],   # CHECKPOINT
			[1460, 475, 130, 18],   # Subida
			[1660, 385, 100, 18],   # Alta
			[1830, 480, 110, 18],   # Descida
			[2020, 560, 140, 18],   # Perto do fim
			[2230, 620, 380, 28],   # Final
		],

			#[0,    620, 320, 28],   # Início — largo para aprender o gelo
			#[400,  550,  70, 18],   # Primeiro gap — estreito, cuidado ao parar
			#[560,  465,  68, 18],   # Sobe um pouco
			#[710,  545,  72, 18],   # Pequeno respiro
			#[860,  455,  68, 18],   # Salto sobre buraco largo
			#[1060, 560, 200, 22],   # CHECKPOINT — largo, jogador respira
			#[1340, 475,  70, 18],   # Retoma dificuldade
			#[1490, 385,  68, 18],   # Alta — cuidado com o overshooting
			#[1638, 475,  70, 18],   # Descida
			#[1800, 555,  72, 18],   # Quase lá
			#[1960, 620, 380, 28],   # Final

		"checkpoints": [
			[1220, 535],
		],
		"hazards": [
			[710, 590, 30, 22],
			[880, 590, 90, 22],
			[1740, 460, 70, 22],
		],
		"pushable_blocks": [
			[180, 580, 40, 40],
		],
		"stars": [
			[645, 430],
			[1710, 355],
			[2085, 530],
			[280, 460],   # Estrela do Bog
		],
		"exit_pos":    [2520, 580],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [160,  560],
		"loopy_start": [2360, 572],
		"loopy_end":   [2780, 572],
	}
