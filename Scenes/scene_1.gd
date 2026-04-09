extends Node2D

## Level Manager - Gerencia tudo no jogo:
## Plataformas, HUD, camera, Loopy, troca de personagem, transicoes.

@onready var rob: CharacterBase = $Rob
@onready var bog: CharacterBase = $Bog
@onready var camera: Camera2D = $Camera2D

var current_character: CharacterBase
var level_nodes: Array[Node] = []  # Nos criados dinamicamente (limpar ao trocar nivel)

# Loopy NPC
var loopy_body: CharacterBody2D = null
var loopy_start: Vector2
var loopy_end: Vector2
var loopy_speed: float = 80.0
var loopy_fleeing: bool = false

# HUD nodes
var hud_layer: CanvasLayer
var label_level_name: Label
var label_modifier: Label
var label_character: Label
var label_lives: Label
var label_switch_hint: Label

# Intro overlay
var intro_overlay: ColorRect
var intro_label_name: Label
var intro_label_desc: Label
var intro_label_modifier: Label
var intro_timer: float = 0.0
var showing_intro: bool = false

# Transicao (fade)
var fade_rect: ColorRect
var fading: bool = false
var fade_alpha: float = 0.0
var fade_direction: int = 0  # 1 = fade in (escurecer), -1 = fade out (clarear)
var on_fade_complete: Callable

# Background
var bg_rect: ColorRect

# Morte (queda)
const DEATH_Y: float = 900.0

# Vitoria overlay
var victory_overlay: ColorRect = null

func _ready():
	_remove_old_static_bodies()
	_create_background()
	_create_hud()
	_create_fade_overlay()
	_setup_characters()
	_load_level()

func _remove_old_static_bodies():
	# Remove geometria antiga da cena (world boundaries, tilemap)
	for child in get_children():
		if child is StaticBody2D or child.get_class() == "TileMap" or child is TileMapLayer:
			child.queue_free()

func _process(delta: float):
	_update_camera(delta)
	_update_loopy(delta)
	_check_death()
	_update_intro(delta)
	_update_fade(delta)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("switch_character") and not showing_intro and not fading:
		_switch_character()
	if event.is_action_pressed("pause"):
		# Simples pause toggle
		get_tree().paused = !get_tree().paused

# ============================================================
# SETUP
# ============================================================

func _setup_characters():
	current_character = rob
	rob.set_active(true)
	bog.set_active(false)

func _load_level():
	_clear_level()

	var level = GameManager.get_current_level()
	var mods = level["modifiers"]

	# Aplicar modificadores nos personagens
	rob.apply_modifiers(mods)
	bog.apply_modifiers(mods)
	rob.revive()
	bog.revive()

	# Posicionar personagens
	var spawn_r = level["spawn_rob"]
	var spawn_b = level["spawn_bog"]
	rob.global_position = Vector2(spawn_r[0], spawn_r[1])
	bog.global_position = Vector2(spawn_b[0], spawn_b[1])
	rob.velocity = Vector2.ZERO
	bog.velocity = Vector2.ZERO

	# Background
	bg_rect.color = level["bg_color"]

	# Criar plataformas
	var plat_color: Color = level["platform_color"]
	for p in level["platforms"]:
		_create_platform(p[0], p[1], p[2], p[3], plat_color)

	# Criar saida do nivel
	var exit = level["exit_pos"]
	_create_level_exit(Vector2(exit[0], exit[1]))

	# Criar Loopy
	loopy_start = Vector2(level["loopy_start"][0], level["loopy_start"][1])
	loopy_end = Vector2(level["loopy_end"][0], level["loopy_end"][1])
	_create_loopy(loopy_start)

	# Resetar camera
	camera.global_position = current_character.global_position

	# Atualizar HUD
	_update_hud()

	# Mostrar intro do nivel
	_show_level_intro(level)

	# Fade in
	_start_fade(-1, Callable())

func _clear_level():
	for node in level_nodes:
		if is_instance_valid(node):
			node.queue_free()
	level_nodes.clear()

	if loopy_body and is_instance_valid(loopy_body):
		loopy_body.queue_free()
		loopy_body = null
	loopy_fleeing = false

# ============================================================
# PLATAFORMAS
# ============================================================

func _create_platform(x: float, y: float, w: float, h: float, color: Color):
	var body = StaticBody2D.new()
	body.position = Vector2(x + w / 2.0, y + h / 2.0)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(w, h)
	shape.shape = rect
	body.add_child(shape)

	# Visual - retangulo colorido
	var visual = ColorRect.new()
	visual.size = Vector2(w, h)
	visual.position = Vector2(-w / 2.0, -h / 2.0)
	visual.color = color
	body.add_child(visual)

	# Borda superior mais clara
	var top_line = ColorRect.new()
	top_line.size = Vector2(w, 3)
	top_line.position = Vector2(-w / 2.0, -h / 2.0)
	top_line.color = color.lightened(0.3)
	body.add_child(top_line)

	add_child(body)
	level_nodes.append(body)

# ============================================================
# SAIDA DO NIVEL
# ============================================================

func _create_level_exit(pos: Vector2):
	var area = Area2D.new()
	area.position = pos
	area.name = "LevelExit"

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(40, 60)
	shape.shape = rect
	area.add_child(shape)

	# Visual - bandeira/portal
	var visual = ColorRect.new()
	visual.size = Vector2(40, 60)
	visual.position = Vector2(-20, -30)
	visual.color = Color(0.2, 0.9, 0.3, 0.8)
	area.add_child(visual)

	# Borda brilhante
	var glow = ColorRect.new()
	glow.size = Vector2(44, 64)
	glow.position = Vector2(-22, -32)
	glow.color = Color(0.3, 1.0, 0.4, 0.3)
	area.add_child(glow)

	# Seta indicando saida
	var arrow_label = Label.new()
	arrow_label.text = ">>>"
	arrow_label.position = Vector2(-18, -50)
	arrow_label.add_theme_font_size_override("font_size", 20)
	arrow_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	area.add_child(arrow_label)

	area.body_entered.connect(_on_exit_body_entered)
	area.collision_layer = 0
	area.collision_mask = 1

	add_child(area)
	level_nodes.append(area)

func _on_exit_body_entered(body: Node):
	if body == current_character and not fading:
		_complete_level()

# ============================================================
# LOOPY NPC
# ============================================================

func _create_loopy(pos: Vector2):
	loopy_body = CharacterBody2D.new()
	loopy_body.position = pos

	# Collision
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(24, 50)
	shape.shape = rect
	shape.position = Vector2(0, 25)
	loopy_body.add_child(shape)

	# Visual simples (silueta colorida)
	var visual = ColorRect.new()
	visual.size = Vector2(24, 50)
	visual.position = Vector2(-12, 0)
	visual.color = Color(0.9, 0.7, 0.2, 0.9)
	loopy_body.add_child(visual)

	# "?" sobre a cabeca
	var question = Label.new()
	question.text = "?"
	question.position = Vector2(-6, -20)
	question.add_theme_font_size_override("font_size", 22)
	question.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	loopy_body.add_child(question)

	# Nome
	var name_label = Label.new()
	name_label.text = "Loopy"
	name_label.position = Vector2(-20, -38)
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.4, 0.7))
	loopy_body.add_child(name_label)

	add_child(loopy_body)
	level_nodes.append(loopy_body)

func _update_loopy(delta: float):
	if not loopy_body or not is_instance_valid(loopy_body):
		return

	# Loopy anda com comportamento "desorientado"
	# Quando jogador chega perto, Loopy foge
	var dist_to_player = loopy_body.global_position.distance_to(current_character.global_position)

	if dist_to_player < 300:
		loopy_fleeing = true

	if loopy_fleeing:
		var dir = (loopy_end - loopy_body.global_position).normalized()
		loopy_body.velocity.x = dir.x * loopy_speed * 1.5

		# Aplicar gravidade
		if not loopy_body.is_on_floor():
			loopy_body.velocity += loopy_body.get_gravity() * delta
		loopy_body.move_and_slide()

		# Se chegou ao fim, desaparece
		if loopy_body.global_position.distance_to(loopy_end) < 30:
			loopy_body.queue_free()
			loopy_body = null
	else:
		# Movimento "desorientado" - vai e volta
		var wobble = sin(Time.get_ticks_msec() * 0.002) * 30.0
		loopy_body.velocity.x = wobble
		if not loopy_body.is_on_floor():
			loopy_body.velocity += loopy_body.get_gravity() * delta
		loopy_body.move_and_slide()

# ============================================================
# CAMERA
# ============================================================

func _update_camera(delta: float):
	if current_character and not current_character.is_dead:
		var target = current_character.global_position
		target.y = min(target.y, 400)  # Limita camera pra nao ir muito baixo
		camera.global_position = camera.global_position.lerp(target, 5.0 * delta)

# ============================================================
# TROCA DE PERSONAGEM
# ============================================================

func _switch_character():
	if current_character == rob:
		current_character = bog
	else:
		current_character = rob

	rob.set_active(current_character == rob)
	bog.set_active(current_character == bog)

	# Efeito visual de troca (scale pulse)
	var tween = create_tween()
	tween.tween_property(current_character, "scale", Vector2(1.2, 0.8), 0.08)
	tween.tween_property(current_character, "scale", Vector2(0.9, 1.1), 0.08)
	tween.tween_property(current_character, "scale", Vector2(1.0, 1.0), 0.06)

	_update_hud()

# ============================================================
# MORTE (QUEDA)
# ============================================================

func _check_death():
	if fading or showing_intro:
		return

	# Verificar se o personagem ativo caiu
	if current_character.global_position.y > DEATH_Y:
		_on_player_died()

	# Verificar o inativo tambem
	var other = bog if current_character == rob else rob
	if other.global_position.y > DEATH_Y and not other.is_dead:
		# Reposicionar inativo perto do ativo
		other.global_position = current_character.global_position + Vector2(-40, -20)
		other.velocity = Vector2.ZERO

func _on_player_died():
	if GameManager.lose_life():
		_start_fade(1, _reload_current_level)
	else:
		_start_fade(1, _go_to_menu)

func _reload_current_level():
	_load_level()

func _go_to_menu():
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# ============================================================
# COMPLETAR NIVEL
# ============================================================

func _complete_level():
	if GameManager.next_level():
		_start_fade(1, _load_next)
	else:
		# Jogo completo!
		_show_victory()

func _load_next():
	_setup_characters()
	_load_level()

func _show_victory():
	if victory_overlay:
		return
	victory_overlay = ColorRect.new()
	victory_overlay.size = Vector2(1152, 648)
	victory_overlay.color = Color(0, 0, 0, 0.85)

	var vbox = VBoxContainer.new()
	vbox.position = Vector2(350, 150)
	vbox.add_theme_constant_override("separation", 20)

	var title = Label.new()
	title.text = "Voce encontrou o Loopy!"
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	vbox.add_child(title)

	var sub = Label.new()
	sub.text = "Os tres amigos estao juntos novamente."
	sub.add_theme_font_size_override("font_size", 22)
	sub.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	vbox.add_child(sub)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer)

	var hint = Label.new()
	hint.text = "Pressione ESPACO para voltar ao menu"
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	vbox.add_child(hint)

	victory_overlay.add_child(vbox)
	hud_layer.add_child(victory_overlay)

	# Esperar input para voltar ao menu
	set_process_unhandled_input(true)
	await get_tree().create_timer(0.5).timeout
	_wait_for_menu_input()

func _wait_for_menu_input():
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
			_go_to_menu()
			return

# ============================================================
# HUD
# ============================================================

func _create_hud():
	hud_layer = CanvasLayer.new()
	hud_layer.layer = 10

	# Barra superior com info
	var top_bar = ColorRect.new()
	top_bar.size = Vector2(1152, 50)
	top_bar.color = Color(0, 0, 0, 0.5)
	hud_layer.add_child(top_bar)

	# Nome do nivel
	label_level_name = Label.new()
	label_level_name.position = Vector2(15, 8)
	label_level_name.add_theme_font_size_override("font_size", 20)
	label_level_name.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	hud_layer.add_child(label_level_name)

	# Modificador ativo
	label_modifier = Label.new()
	label_modifier.position = Vector2(15, 32)
	label_modifier.add_theme_font_size_override("font_size", 13)
	label_modifier.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	hud_layer.add_child(label_modifier)

	# Personagem ativo
	label_character = Label.new()
	label_character.position = Vector2(850, 8)
	label_character.add_theme_font_size_override("font_size", 18)
	label_character.add_theme_color_override("font_color", Color(0.5, 0.9, 1.0))
	hud_layer.add_child(label_character)

	# Vidas
	label_lives = Label.new()
	label_lives.position = Vector2(850, 30)
	label_lives.add_theme_font_size_override("font_size", 16)
	label_lives.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	hud_layer.add_child(label_lives)

	# Dica de controle
	label_switch_hint = Label.new()
	label_switch_hint.position = Vector2(1000, 8)
	label_switch_hint.text = "[TAB] Trocar"
	label_switch_hint.add_theme_font_size_override("font_size", 14)
	label_switch_hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	hud_layer.add_child(label_switch_hint)

	add_child(hud_layer)

func _update_hud():
	var level = GameManager.get_current_level()
	var lvl_num = GameManager.current_level_index + 1
	var total = GameManager.get_level_count()
	label_level_name.text = "Fase %d/%d: %s" % [lvl_num, total, level["name"]]
	label_modifier.text = level["modifier_hint"]
	label_character.text = "Ativo: %s" % current_character.character_name
	label_lives.text = "Vidas: %d" % GameManager.lives

# ============================================================
# INTRO DO NIVEL
# ============================================================

func _show_level_intro(level: Dictionary):
	showing_intro = true
	intro_timer = 3.0

	if not intro_overlay:
		intro_overlay = ColorRect.new()
		intro_overlay.size = Vector2(1152, 648)
		intro_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

		intro_label_name = Label.new()
		intro_label_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		intro_label_name.position = Vector2(200, 200)
		intro_label_name.size = Vector2(752, 60)
		intro_label_name.add_theme_font_size_override("font_size", 44)
		intro_overlay.add_child(intro_label_name)

		intro_label_desc = Label.new()
		intro_label_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		intro_label_desc.position = Vector2(200, 280)
		intro_label_desc.size = Vector2(752, 40)
		intro_label_desc.add_theme_font_size_override("font_size", 22)
		intro_label_desc.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
		intro_overlay.add_child(intro_label_desc)

		intro_label_modifier = Label.new()
		intro_label_modifier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		intro_label_modifier.position = Vector2(200, 340)
		intro_label_modifier.size = Vector2(752, 40)
		intro_label_modifier.add_theme_font_size_override("font_size", 26)
		intro_label_modifier.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
		intro_overlay.add_child(intro_label_modifier)

		var skip_label = Label.new()
		skip_label.text = "Pressione ESPACO para comecar"
		skip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		skip_label.position = Vector2(200, 430)
		skip_label.size = Vector2(752, 30)
		skip_label.add_theme_font_size_override("font_size", 16)
		skip_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
		intro_overlay.add_child(skip_label)

		hud_layer.add_child(intro_overlay)

	var lvl_num = GameManager.current_level_index + 1
	intro_label_name.text = "Fase %d - %s" % [lvl_num, level["name"]]
	intro_label_name.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5))
	intro_label_desc.text = level["description"]
	intro_label_modifier.text = level["modifier_hint"]
	intro_overlay.color = Color(0, 0, 0, 0.8)
	intro_overlay.visible = true

func _update_intro(delta: float):
	if not showing_intro:
		return
	intro_timer -= delta

	# Pular intro com espaco
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		intro_timer = 0

	if intro_timer <= 0:
		showing_intro = false
		if intro_overlay:
			intro_overlay.visible = false

# ============================================================
# FADE (TRANSICAO)
# ============================================================

func _create_fade_overlay():
	fade_rect = ColorRect.new()
	fade_rect.size = Vector2(1152, 648)
	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_layer.add_child(fade_rect)

func _start_fade(direction: int, callback: Callable):
	fading = true
	fade_direction = direction
	if direction == 1:
		fade_alpha = 0.0
	else:
		fade_alpha = 1.0
	on_fade_complete = callback

func _update_fade(delta: float):
	if not fading:
		fade_rect.color.a = 0.0
		return

	fade_alpha += fade_direction * delta * 2.5
	fade_rect.color.a = clamp(fade_alpha, 0.0, 1.0)

	if (fade_direction == 1 and fade_alpha >= 1.0) or (fade_direction == -1 and fade_alpha <= 0.0):
		fading = false
		if on_fade_complete.is_valid():
			on_fade_complete.call()

# ============================================================
# BACKGROUND
# ============================================================

func _create_background():
	bg_rect = ColorRect.new()
	bg_rect.size = Vector2(5000, 2000)
	bg_rect.position = Vector2(-1000, -500)
	bg_rect.color = Color(0.15, 0.18, 0.28)
	bg_rect.z_index = -100
	add_child(bg_rect)
