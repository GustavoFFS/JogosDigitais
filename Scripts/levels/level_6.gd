extends RefCounted
class_name Level6Data
## Fase 6 - Gravidade Invertida
## Ilhas que invertem a gravidade ao serem pisadas.
## Dificuldade alta — combinacao de pulo alto e gravidade negativa.

static func get_data() -> Dictionary:
	return {
		"name": "Gravidade Invertida",
		"description": "O chá fez Loopy subir pelos tetos...\ncuidado com o que está em cima!",
		"modifier_hint": "Gravidade Invertida  ·  Pense ao contrário!",
		"bg_color":       Color(0.06, 0.04, 0.12),
		"platform_color": Color(0.45, 0.22, 0.70),
		"modifiers": {
			"speed_mult":   1.0,
			"jump_mult":    1.3,
			"gravity_mult": 1.1,
			"friction":     1.0,
			"air_control":  1.0,
		},
		"platforms": [
			[0,    620, 300, 28],   # Início
			[380,  540, 120, 18],   # Primeiro salto
			[580,  440, 100, 18],   # Subida
			[760,  540, 110, 18],   # Descida
			[950,  440, 100, 18],   # Salto
			[1130, 555, 200, 22],   # CHECKPOINT 1
			[1410, 460, 110, 18],
			[1600, 360, 100, 18],
			[1800, 460, 110, 18],
			[1990, 555, 200, 22],   # CHECKPOINT 2
			[2270, 460, 100, 18],
			[2460, 360,  90, 18],
			[2640, 460, 100, 18],
			[2820, 620, 420, 28],   # Final
		],
		"moving_platforms": [],
		"checkpoints": [
			[1190, 530],
			[2050, 530],
		],
		"hazards": [
			[500,  592, 55, 22],
			[880,  592, 45, 22],
			[1530, 592, 50, 22],
			[1910, 592, 45, 22],
			[2390, 592, 55, 22],
		],
		"exit_pos":    [3080, 590],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [155,  560],
		"loopy_start": [3000, 572],
		"loopy_end":   [3000, 572],
	}
