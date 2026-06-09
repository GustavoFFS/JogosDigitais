extends CharacterBase

## Rob - Personagem agil e rapido.
## Habilidade: DASH — surto horizontal na direcao que olha.
## Tecla Z para usar. Cooldown: 2.2s.

# ============================================================
# INICIALIZACAO
# ============================================================

func _ready() -> void:
	add_to_group("pushable")
	character_name     = "Rob"
	base_speed         = 300.0
	base_jump_velocity = -420.0
	can_push           = false
	anim_suffix        = "_2"
	ability_cooldown   = 0.0

# ============================================================
# GAME LOOP (INPUT -> UPDATE -> RENDER)
# ============================================================
# Nota: O _physics_process agora vive APENAS na CharacterBase.

## 1. ETAPA DE INPUT
func _game_loop_input() -> void:
	# Sempre chame o super para garantir que a CharacterBase leia os botões
	super._game_loop_input()

## 2. ETAPA DE UPDATE
func _game_loop_update(delta: float) -> void:
	# Sempre chame o super para que a gravidade e o move_and_slide funcionem
	super._game_loop_update(delta)

## 3. ETAPA DE RENDER
func _game_loop_render() -> void:
	# Sempre chame o super para que a CharacterBase atualize as animações
	super._game_loop_render()

# ============================================================
# HABILIDADE
# ============================================================

func _use_ability() -> void:
	if not sprite or is_locked:
		return
		
	is_locked = true
	lock_timer = 0.15 
	
	var dir := -1.0 if sprite.flip_h else 1.0
	velocity.x = dir * base_speed * speed_mult * 2.8
	
	SoundManager.play_sfx("dash")
	
	var main_scene = get_parent()
	if main_scene:
		if main_scene.has_method("apply_shake"):
			main_scene.apply_shake(3.0)
		if main_scene.has_method("spawn_dash_ghosts"):
			main_scene.spawn_dash_ghosts(self, 0.15)
	
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(0.55, 0.88, 1.0, 1.0), 0.04)
	tw.tween_property(sprite, "modulate", Color(1.0,  1.0,  1.0, 1.0), 0.22)
