extends CharacterBase

## Rob - Personagem agil e rapido.
## Habilidade: DASH — surto horizontal na direcao que olha.
## Tecla Z para usar. Cooldown: 2.2s.

func _ready() -> void:
	character_name   = "Rob"
	base_speed       = 300.0
	base_jump_velocity = -420.0
	can_push         = false
	anim_suffix      = "_2"
	ability_cooldown = 2.2

func _use_ability() -> void:
	if not sprite:
		return
	var dir := -1.0 if sprite.flip_h else 1.0
	velocity.x = dir * base_speed * speed_mult * 2.8
	# Flash visual azul-claro (cor do Rob)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(0.55, 0.88, 1.0, 1.0), 0.04)
	tw.tween_property(sprite, "modulate", Color(1.0,  1.0,  1.0, 1.0), 0.22)
