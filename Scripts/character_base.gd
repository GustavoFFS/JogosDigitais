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
var is_locked: bool = false # Nova variável para travar o movimento normal

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

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_update_timers(delta)
	_apply_gravity(delta)

	var direction := 0.0

	if is_active:
		direction = _get_movement_input()
		_handle_jump()
		if Input.is_action_just_pressed("ability") and ability_timer <= 0.0:
			_use_ability()
			ability_timer = ability_cooldown

	_apply_horizontal_movement(direction, delta)
	move_and_slide()
	_handle_push()
	_update_animation(direction)

func _update_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)
	if jump_buffer_timer > 0:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)
	if ability_timer > 0:
		ability_timer = max(ability_timer - delta, 0.0)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_mult * delta

func _get_movement_input() -> float:
	return Input.get_axis("move_left", "move_right")

func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	var can_jump := is_on_floor() or coyote_timer > 0
	if jump_buffer_timer > 0 and can_jump:
		velocity.y      = get_jump()
		coyote_timer    = 0.0
		jump_buffer_timer = 0.0

func _use_ability() -> void:
	pass  # sobrescrito pelas subclasses

func _apply_horizontal_movement(direction: float, _delta: float) -> void:
	if is_locked: return # Se estiver travado, ignora o lerp e o input normal
	if direction != 0:
		var target := direction * get_speed()
		if is_on_floor():
			velocity.x = lerp(velocity.x, target, friction)
		else:
			velocity.x = lerp(velocity.x, target, clamp(air_control * friction, 0.02, 1.0))
		if sprite:
			sprite.flip_h = direction < 0
	else:
		if is_active:
			if is_on_floor():
				velocity.x = lerp(velocity.x, 0.0, friction)
			else:
				velocity.x = lerp(velocity.x, 0.0, clamp(air_control * 0.5, 0.01, 1.0))
		else:
			velocity.x = move_toward(velocity.x, 0, base_speed * 0.05)

func _handle_push() -> void:
	if not can_push or not is_active:
		return
	for i in get_slide_collision_count():
		var col     := get_slide_collision(i)
		var collider := col.get_collider()
		if collider is RigidBody2D and collider.is_in_group("pushable"):
			var push_dir := col.get_normal() * -1
			collider.apply_central_force(push_dir * push_force)

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
