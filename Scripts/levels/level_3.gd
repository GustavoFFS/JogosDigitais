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
			{"speaker": "Bog", "text": "Deixa comigo, vá na frente!"},
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
			[1650,  460, 200, 18],   # Checkpoint
			[2050, 560, 900, 18],   
			[2950, 358, 18, 360],   
			[1900, 700, 200, 18],
			[2200, 700, 200, 18], 
			[2500, 700, 200, 18], 
			[2900, 700, 50, 18], 
			#[2040, 560, 120, 18],  
			#[2230, 620, 360, 28],
		],
		"checkpoints": [
			[1750, 430],
		],
		
		"keys": [
			[1, 2900, 650],
		],
		"locks": [
			[1, 2200, 380, 30, 180],
		],
		
		"gravity_zones": [
			[1900, 578, 200, 122],
			#[2200, 578, 200, 122],
			#[2500, 578, 200, 122],
		],
		
		"hazards": [
			[ 2200, 358, 750, 22],

		],
		"switches": [
			[1, 230, 612, 40, 8],
		],
		"gates": [
			[1, 1220, 250, 16, 150],  # Reajustado para a nova altura de plat 2
		],
		
		
		
		"crumbling_platforms": [
			[360, 560, 120, 18],
			[560, 480, 110, 18],
			[760, 530, 120, 18],
			[960, 460, 120, 18],
			[1160, 400, 120, 18]
		],
		"stars": [
			[2850, 480],   # Rebaixado (era 385)
			[615, 400],  # Rebaixado (era 220)
			[2100, 350],  # Rebaixado (era 415)
		],
		"exit_pos":    [2510, 520],
		"spawn_rob":   [60,   560],
		"spawn_bog":   [100,  560],
		"loopy_start": [2360, 520],
		"loopy_end":   [2510, 520],
	}
