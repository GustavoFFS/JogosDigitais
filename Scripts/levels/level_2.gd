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
			"friction":     0.10,
			"air_control":  0.78,
		},
		"platforms": [
			[0,    620, 320, 28],
			[400,  550, 130, 18],
			[600,  465,  90, 18],
			[760,  545, 160, 18],
			[990,  455, 100, 18],
			[1160, 560, 220, 22],   # CHECKPOINT
			[1460, 475, 130, 18],
			[1660, 385, 100, 18],
			[1830, 480, 110, 18],
			[2020, 560, 140, 18],
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
			[ 340, 600,  50, 22],
			[ 710, 590,  30, 22],
			[ 920, 590,  60, 22],
			[1380, 540,  60, 22],
			[1740, 460,  60, 22],
			[2160, 540,  50, 22],
		],
		"pushable_blocks": [
			[180, 580, 40, 40],
		],
		"stars": [
			[510, 460],   # No gap deslizante após o início — escorregar e cair = morte
			[1700, 290],  # Bem acima da plataforma 1640/380
			[2160, 470],  # No gap final — desliza demais e cai no espinho
			[280, 460],   # Estrela do Bog
		],
		"exit_pos":    [2520, 580],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [160,  560],
		"loopy_start": [2360, 572],
		"loopy_end":   [2780, 572],
	}
