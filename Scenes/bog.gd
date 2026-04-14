extends CharacterBase

## Bog - Personagem robusto e forte.
## Habilidade: IMPACTO — no ar: despenca rapido; no chao: empurrao frontal.
## Tecla Z para usar. Cooldown: 2.8s.

func _ready() -> void:
	character_name     = "Bogo"
	base_speed         = 220.0
	base_jump_velocity = -380.0
	can_push           = true
	push_force         = 400.0
	anim_suffix        = ""
	ability_cooldown   = 2.8

func _use_ability() -> void:
	if not sprite:
		return
	if not is_on_floor():
		# No ar: despenca verticalmente (ground pound)
		velocity.y = 680.0
		velocity.x = 0.0
	else:
		is_locked = true
		# No chao: empurrao frontal forte
		var dir := -1.0 if sprite.flip_h else 1.0
		velocity.x = dir * base_speed * speed_mult * 3.2
		get_tree().create_timer(0.2).timeout.connect(func(): is_locked = false)
	# Flash visual laranja (cor do Bog)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(1.0, 0.60, 0.22, 1.0), 0.04)
	tw.tween_property(sprite, "modulate", Color(1.0, 1.0,  1.0,  1.0), 0.28)
