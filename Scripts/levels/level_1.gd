extends RefCounted
class_name Level1Data

## Fase 1 - Ruas da Cidade
## Controles normais. Tutorial com obstaculos moderados.

static func get_data() -> Dictionary:
	return {
		"name": "Ruas da Cidade",
		"description": "Rob e Bog viram Loopy sair do Café Loop com olhar distante...\na busca começa aqui nas ruas!",
		"modifier_hint": "Controles Normais  ·  Aprenda o básico!",
		"ambient_type": "city",
		"dialogues": [
			{"speaker": "Bog", "text": "Viu pra onde o Loopy foi? Onde esse garoto foi se meter?"},
			{"speaker": "Rob", "text": "Ele saiu correndo do café... vamos atrás, rápido!"},
			{"speaker": "Bog", "text": "Calma, esse equipamento tá pesado..."},
			{"speaker": "Rob", "text": "Droga, quem era aquela mulher e aquela... sopa?"},
			{"speaker": "Bog", "text": "Isso não tá me cheirando bem..."},
			{"speaker": "Bog", "text": "Posso utilizar a minha habilidade para te ajudar a alcançar aquela plataforma [Pulo + Z]."},
			{"speaker": "Rob", "text": "Com a minha habilidade, vamos ainda mais longe [Pressione Z]."},
			{"speaker": "Bog", "text": "Vá na frente Rob, eu já te alcanço!"},

		],
		"bg_color":       Color(0.742, 0.81, 0.794, 1.0),
		"bg_image": "res://Assets/Backgrounds/cidade.png", # <--- ADICIONE AQUI
		"bg_size": [70000.0, 1000.0], # Vai repetir a imagem horizontalmente por 8000 pixels!
		"platform_color": Color(0.38, 0.40, 0.48),
		"modifiers": {
			"speed_mult":   1.0,
			"jump_mult":    1.0,
			"gravity_mult": 1.0,
			"friction":     1.0,
			"air_control":  1.0,
		},
		# [x, y, largura, altura]
		"platforms": [
			[-200,    620, 560, 28],   # Plataforma Inicial
			[580,  450, 180, 18],   # Grande Salto
			[1150, 555, 200, 22],   # Checkpoint
			[2380, 555, 160, 18],   # Pós Plataforma que Move
			[2620, 350, 20, 298],   # Jump Pad
			[2620, 620, 420, 28],   # Final
		],
		
			"moving_platforms": [
			{ 
				"start_pos": Vector2(1400.0, 470.0), # Antigos x_min e y
				"end_pos": Vector2(1600.0, 470.0),   # Antigos x_max e y
				"w": 110.0, 
				"h": 18.0, 
				"speed": 120.0,
				"to_end": true 
			},
			{ 
				"start_pos": Vector2(1860.0, 465.0), # Antigos x_min e y
				"end_pos": Vector2(1860.0, 320.0),   # Antigos x_max e y
				"w": 110.0, 
				"h": 18.0, 
				"speed": 120.0,
				"to_end": true 
			},
		],

		"checkpoints": [
			[1260, 530],
		],
		
		"jump_pads": [
			[2500, 542, 40, 12],
		],
		
		"hazards": [
			[950, 555, 200, 22],   # Antes Plataforma Salto Longo
			[1655, 456,  150, 22],   # Pós Plataforma que Move
			[3040, 620,  350, 22],   # Pós Final
		],
		"pushable_blocks": [
			[0, 580, 40, 40],
		],
		"stars": [
			[300, 360],   # Estrela do Bog — empurre o bloco para baixo dela
			[970, 400],   # Sobre o gap, requer pulo preciso entre plataformas
			[1875, 160],  # Bem acima da plataforma alta — exige pulo no limite
			[2630, 230],  # No gap antes da saída
		],
		"exit_pos":    [2940, 580],
		"spawn_rob":   [-140,   560],
		"spawn_bog":   [-40,  560],
		"loopy_start": [2780, 572],
		"loopy_end":   [2960, 572],
	}
