extends CharacterBase

## Bog - Personagem robusto e forte.
## Habilidade: IMPACTO — no ar: despenca rápido e arremessa objetos próximos.
## Tecla Z para usar. Cooldown: 2.8s.

var is_ground_pounding := false
var impact_radius := 150.0  # Área de efeito do estrondo
var impact_power := 600.0   # Força do arremesso

# ============================================================
# INICIALIZACAO
# ============================================================

func _ready() -> void:
	character_name     = "Bog"
	base_speed         = 220.0
	base_jump_velocity = -380.0
	can_push           = true
	push_force         = 120.0
	anim_suffix        = ""
	ability_cooldown   = 0.1

# ============================================================
# GAME LOOP (INPUT -> UPDATE -> RENDER)
# ============================================================

func _physics_process(delta: float) -> void:
	_game_loop_input()
	_game_loop_update(delta)
	_game_loop_render()

## 1. ETAPA DE INPUT
func _game_loop_input() -> void:
	# Processamento de inputs específicos do Bog que não estejam na CharacterBase
	pass

## 2. ETAPA DE UPDATE (Física e Lógica)
func _game_loop_update(delta: float) -> void:
	# Agora chamamos o Update da classe pai diretamente!
	super._game_loop_update(delta) 
	
	# Se estava caindo no impacto e finalmente bateu no chão
	if is_ground_pounding and is_on_floor():
		_apply_ground_impact()
		is_ground_pounding = false
		is_locked = false # Destrava o movimento para o jogador voltar a andar

## 3. ETAPA DE RENDER (Efeitos e Visuais)
func _game_loop_render() -> void:
	# Atualizações visuais contínuas por frame
	pass

# ============================================================
# HABILIDADE E EFEITOS
# ============================================================

func _use_ability() -> void:
	# Não faz nada se estiver no chão ou se já estiver executando o golpe
	if not sprite or is_on_floor() or is_ground_pounding:
		return
	
	is_ground_pounding = true
	is_locked = true # Trava o input horizontal (herança do CharacterBase)
	
	# Despenca rápido verticalmente
	velocity.y = 800.0
	velocity.x = 0.0
	
	# Efeito visual de flash do personagem
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(1.0, 0.60, 0.22, 1.0), 0.04)
	tw.tween_property(sprite, "modulate", Color(1.0, 1.0,  1.0,  1.0), 0.28)

func _apply_ground_impact() -> void:
	var pushables = get_tree().get_nodes_in_group("pushable")
	
	for obj in pushables:
		if not is_instance_valid(obj) or obj == self:
			continue
			
		var distance = global_position.distance_to(obj.global_position)
		
		if distance <= impact_radius:
			# Proporção da distância: 0.0 (colado) até 1.0 (no limite)
			var distance_ratio = clamp(distance / impact_radius, 0.0, 1.0)
			
			# --- NOVA LÓGICA DE DIREÇÃO E ÂNGULO ---
			var dir_to_obj = global_position.direction_to(obj.global_position)
			var dir_x_sign = sign(dir_to_obj.x)
			
			# Se o objeto estiver perfeitamente alinhado no eixo X, joga para a direita por padrão
			if dir_x_sign == 0: 
				dir_x_sign = 1.0 
			
			# Eixo X: Perto = 0.1 (quase sem movimento horizontal), Longe = 1.0 (muito horizontal)
			var x_val = lerp(0.1, 1.0, distance_ratio) * dir_x_sign
			
			# Eixo Y: Perto = -1.0 (muito vertical), Longe = -0.3 (pouco vertical, voa rasante)
			var y_val = lerp(-1.0, -0.3, distance_ratio)
			
			# Cria a nova direção com base nos valores e normaliza para manter a força consistente
			var dir = Vector2(x_val, y_val).normalized()
			# --------------------------------------
			
			# Lógica de força que já havíamos feito
			var power_multiplier = lerp(1.0, 0.2, distance_ratio)
			var applied_power = impact_power * power_multiplier
			
			if obj is RigidBody2D:
				obj.apply_impulse(dir * applied_power)
				
			elif obj is CharacterBody2D:
				# Desgruda do chão para evitar atrito falso do Godot
				obj.global_position.y -= 2.0 
				
				# Aplica a força na direção calculada
				obj.velocity = dir * applied_power
				
				if "is_locked" in obj:
					obj.is_locked = true
					if "lock_timer" in obj:
						obj.lock_timer = 0.5 * power_multiplier
