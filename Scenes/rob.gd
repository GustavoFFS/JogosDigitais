extends CharacterBase

## Rob - Personagem agil e rapido.
## Impulsivo, energetico e determinado.
## Maior velocidade, melhor resposta em movimentos rapidos.

func _ready():
	character_name = "Rob"
	base_speed = 300.0
	base_jump_velocity = -420.0
	can_push = false
	anim_suffix = "_2"
