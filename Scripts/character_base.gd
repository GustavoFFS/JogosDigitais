extends CharacterBody2D
class_name CharacterBase

## Classe base para personagens jogaveis.
## Suporta modificadores de movimento e sistema de habilidade unica por personagem.

@export var base_speed: float = 300.0
@export var base_jump_velocity: float = -450.0
@export var character_name: String = "Character"

var can_push:   bool  = false
var push_force: float = 300.0

var is_active: bool = false
var is_dead:   bool = false

# Modificadores de movimento
var speed_mult:   float = 1.0
var jump_mult:    float = 1.0
var gravity_mult: float = 1.0
var friction:     float = 1.0
var air_control:  float = 1.0

# Sistema de controle de inatividade (trava de input)
var is_locked:  bool  = false 
var lock_timer: float = 0.0 
var _was_on_floor: bool = true 

# Coyote time
var coyote_timer: float = 0.0
const COYOTE_TIME: float = 0.1

# Jump buffer
var jump_buffer_timer: float = 0.0
const JUMP_BUFFER_TIME: float = 0.12

# Habilidade unica (cooldown controlado pela subclasse)
var ability_cooldown: float = 3.0
var ability_timer:    float = 0.0

# Animacao
@onready var anim:   AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D        = $Sprite2D
var anim_suffix: String = ""

# Variáveis de cache do Game Loop (Input)
var _input_direction: float = 0.0
var _input_jump: bool = false
var _input_ability: bool = false

# ============================================================
# GETTERS
# ============================================================

func get_speed() -> float:
	return base_speed * speed_mult

func get_jump() -> float:
	return base_jump_velocity * jump_mult

func get_ability_ratio() -> float:
	if ability_cooldown <= 0:
		return 1.0
	return 1.0 - clamp(ability_timer / ability_cooldown, 0.0, 1.0)

# ============================================================
# GAME LOOP (INPUT -> UPDATE -> RENDER)
# ============================================================

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_game_loop_input()
	_game_loop_update(delta)
	_game_loop_render()

## 1. ETAPA DE INPUT
func _game_loop_input() -> void:
	_input_direction = 0.0
	_input_jump = false
	_input_ability = false

	var main_scene = get_parent()
	var exiting := false
	if main_scene and "is_exiting" in main_scene and main_scene.is_exiting:
		exiting = true

	if is_active and not exiting:
		_input_direction = Input.get_axis("move_left", "move_right")
		_input_jump = Input.is_action_just_pressed("jump")
		_input_ability = Input.is_action_just_pressed("ability")

## 2. ETAPA DE UPDATE (Física, Timers e Movimentação)
func _game_loop_update(delta: float) -> void:
	var on_floor := is_on_floor()
	if on_floor and not _was_on_floor:
		_on_land()
	_was_on_floor = on_floor

	_update_timers(delta)
	_apply_gravity(delta)

	if is_active:
		_handle_jump()
		if _input_ability and ability_timer <= 0.0:
			_use_ability()
			ability_timer = ability_cooldown

	# 1. Calcula o movimento horizontal do jogador (aplica o lerp/atrito normal)
	_apply_horizontal_movement(_input_direction, delta)

	# 2. Resgata a velocidade da plataforma calculada pela cena principal
	var plat_vel: Vector2 = get_meta("platform_velocity", Vector2.ZERO)
	
	# 3. INTERCEPTAÇÃO DA FÍSICA:
	# Somamos a velocidade da plataforma logo antes do move_and_slide().
	velocity.x += plat_vel.x
	if abs(plat_vel.y) > 0.1:
		velocity.y = plat_vel.y

	# 4. Executa a física oficial do Godot com os vetores unidos
	move_and_slide()

	# 5. ISOLAMENTO DO ATRITO:
	# Subtraímos a velocidade da plataforma imediatamente após o movimento.
	velocity.x -= plat_vel.x
	
	# Limpa o meta para que o personagem pare de se mover se sair da plataforma
	set_meta("platform_velocity", Vector2.ZERO)

	_handle_push()

## 3. ETAPA DE RENDER (Animações e Efeitos Visuais)
func _game_loop_render() -> void:
	_update_animation(_input_direction)
	# Nota: A modulação de cor (dano, inatividade) é tratada via eventos (set_active/die/revive)
	# ou interpolada nas próprias habilidades (Rob/Bog), então não precisa ser forçada aqui.

# ============================================================
# LÓGICA DE FÍSICA E TIMERS
# ============================================================

func _update_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)
		
	if jump_buffer_timer > 0:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)
		
	if ability_timer > 0:
		ability_timer = max(ability_timer - delta, 0.0)
		
	# Gerenciador de tempo para estados travados (stun, dash, empurrões)
	if lock_timer > 0:
		lock_timer -= delta
		if lock_timer <= 0:
			is_locked = false

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_mult * delta

func _handle_jump() -> void:
	if _input_jump:
		jump_buffer_timer = JUMP_BUFFER_TIME
		
	var can_jump := is_on_floor() or coyote_timer > 0
	
	if jump_buffer_timer > 0 and can_jump:
		velocity.y        = get_jump()
		coyote_timer      = 0.0
		jump_buffer_timer = 0.0
		SoundManager.play_sfx("jump")
		var main_scene = get_parent()
		if main_scene and main_scene.has_method("spawn_jump_particles"):
			main_scene.spawn_jump_particles(global_position, character_name)

func _on_land() -> void:
	var main_scene = get_parent()
	if main_scene and main_scene.has_method("spawn_land_particles"):
		main_scene.spawn_land_particles(global_position, character_name)

func _use_ability() -> void:
	pass  # sobrescrito pelas subclasses

func _apply_horizontal_movement(direction: float, delta: float) -> void:
	if is_locked: return # Se estiver travado, ignora o atrito e mantém o voo
	
	var is_ice := friction < 0.2
	
	if direction != 0:
		var target := direction * get_speed()
		if is_on_floor():
			if is_ice:
				# Se estiver acelerando na direção do movimento, acelera um pouco mais rápido
				if sign(direction) == sign(velocity.x) or abs(velocity.x) < 15.0:
					velocity.x = lerp(velocity.x, target, friction * 1.2)
				else:
					# Se estiver freando ou mudando de direção, desliza mais
					velocity.x = lerp(velocity.x, target, friction * 0.4)
			else:
				velocity.x = lerp(velocity.x, target, friction)
		else:
			if is_ice:
				velocity.x = lerp(velocity.x, target, clamp(air_control * friction * 0.7, 0.01, 1.0))
			else:
				velocity.x = lerp(velocity.x, target, clamp(air_control * friction, 0.02, 1.0))
		if sprite:
			sprite.flip_h = direction < 0
	else:
		# --- DIREÇÃO = 0 (Nenhum botão pressionado) ---
		if is_active:
			if is_on_floor():
				if is_ice:
					# Desaceleração muito lenta no gelo (deslize longo)
					velocity.x = lerp(velocity.x, 0.0, friction * 0.3)
				else:
					velocity.x = lerp(velocity.x, 0.0, friction)
			else:
				velocity.x = lerp(velocity.x, 0.0, clamp(air_control * 0.5, 0.01, 1.0))
		else:
			# PERSONAGEM INATIVO: Física realista.
			if is_on_floor():
				if is_ice:
					velocity.x = lerp(velocity.x, 0.0, friction * 0.3)
				else:
					velocity.x = lerp(velocity.x, 0.0, friction)
			else:
				# NO AR: Comportamento Parabólico (mantém a inércia do arremesso do Bog)
				velocity.x = move_toward(velocity.x, 0.0, 80.0 * delta)
				
	# Partículas visuais de deslize no gelo
	if is_on_floor() and is_ice and abs(velocity.x) > 40.0:
		if direction == 0 or sign(direction) != sign(velocity.x):
			var main_scene = get_parent()
			if main_scene and main_scene.has_method("_spawn_dust") and randf() < 0.20:
				main_scene._spawn_dust(global_position + Vector2(0, 20), Color(0.90, 0.95, 1.0, 0.75), 2, -10.0)

func _handle_push() -> void:
	if not can_push or not is_active:
		return
	for i in get_slide_collision_count():
		var col      := get_slide_collision(i)
		var collider := col.get_collider()
		if collider is RigidBody2D and collider.is_in_group("pushable"):
			var push_dir := col.get_normal() * -1
			collider.apply_central_force(push_dir * push_force)

# ============================================================
# ANIMAÇÃO E EVENTOS
# ============================================================

func _update_animation(direction: float) -> void:
	if not anim:
		return
	if not is_on_floor():
		_play_anim("Jump" + anim_suffix)
	elif abs(direction) > 0.1:
		_play_anim("Walk" + anim_suffix)
	else:
		_play_anim("Idle" + anim_suffix)

func _play_anim(anim_name: String) -> void:
	if anim.has_animation(anim_name) and anim.current_animation != anim_name:
		anim.play(anim_name)

func apply_modifiers(mods: Dictionary) -> void:
	speed_mult   = mods.get("speed_mult",   1.0)
	jump_mult    = mods.get("jump_mult",    1.0)
	gravity_mult = mods.get("gravity_mult", 1.0)
	friction     = mods.get("friction",     1.0)
	air_control  = mods.get("air_control",  1.0)

func reset_modifiers() -> void:
	speed_mult   = 1.0
	jump_mult    = 1.0
	gravity_mult = 1.0
	friction     = 1.0
	air_control  = 1.0

func set_active(active: bool) -> void:
	is_active = active
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1) if active else Color(0.5, 0.5, 0.6, 0.8)

func die() -> void:
	is_dead  = true
	velocity = Vector2.ZERO
	if sprite:
		sprite.modulate = Color(1, 0.3, 0.3, 0.6)

func revive() -> void:
	is_dead       = false
	velocity      = Vector2.ZERO
	ability_timer = 0.0
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)
