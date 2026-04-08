extends CharacterBase

## Bogo - Personagem robusto e forte.
## Calmo, estrategico e persistente.
## Maior estabilidade, pode empurrar objetos.

func _ready():
	character_name = "Bogo"
	base_speed = 220.0
	base_jump_velocity = -380.0
	can_push = true
	push_force = 400.0
	anim_suffix = ""
