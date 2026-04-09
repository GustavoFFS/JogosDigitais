extends Node2D

## Cena principal - Lost & Loopy
## Gerencia plataformas, personagens, camera, Loopy e transicoes de nivel.
## A HUD e os overlays de intro/fade estao em Scripts/hud.gd

@onready var rob:    CharacterBase = $Rob
@onready var bog:    CharacterBase = $Bog
@onready var camera: Camera2D      = $Camera2D

var hud: GameHUD
var current_character: CharacterBase
var level_nodes: Array[Node] = []

# Loopy NPC
var loopy_body:    CharacterBody2D = null
var loopy_start:   Vector2
var loopy_end:     Vector2
var loopy_fleeing: bool = false
const LOOPY_SPEED: float = 80.0

# Background dinamico
var bg_rect: ColorRect

# Tela de vitoria
var victory_overlay: ColorRect = null

const DEATH_Y: float = 900.0

# ============================================================
# INICIALIZACAO
# ============================================================

func _ready() -> void:
	_remove_old_static_bodies()
	_create_background()
	hud = GameHUD.new()
	add_child(hud)
	_setup_characters()
	_load_level()

func _remove_old_static_bodies() -> void:
	for child in get_children():
		if child is StaticBody2D or child.get_class() == "TileMap" or child is TileMapLayer:
			child.queue_free()

func _process(delta: float) -> void:
	_update_camera(delta)
	_update_loopy(delta)
	_check_death()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_character") and not hud.showing_intro and not hud.fading:
		_switch_character()
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused

# ============================================================
# CARREGAMENTO DE FASE
# ============================================================

func _setup_characters() -> void:
	current_character = rob
	rob.set_active(true)
	bog.set_active(false)

func _load_level() -> void:
	_clear_level()

	var level := GameManager.get_current_level()
	var idx   := GameManager.current_level_index

	# Aplicar modificadores e reviver personagens
	rob.apply_modifiers(level["modifiers"])
	bog.apply_modifiers(level["modifiers"])
	rob.revive()
	bog.revive()

	# Posicionar personagens
	rob.global_position = Vector2(level["spawn_rob"][0], level["spawn_rob"][1])
	bog.global_position = Vector2(level["spawn_bog"][0], level["spawn_bog"][1])
	rob.velocity        = Vector2.ZERO
	bog.velocity        = Vector2.ZERO

	# Criar geometria da fase
	bg_rect.color = level["bg_color"]
	for p in level["platforms"]:
		_create_platform(p[0], p[1], p[2], p[3], level["platform_color"])

	_create_level_exit(Vector2(level["exit_pos"][0], level["exit_pos"][1]))

	loopy_start = Vector2(level["loopy_start"][0], level["loopy_start"][1])
	loopy_end   = Vector2(level["loopy_end"][0],   level["loopy_end"][1])
	_create_loopy(loopy_start)

	# Camera e HUD
	camera.global_position = current_character.global_position
	hud.update_level_info(level, idx, GameManager.get_level_count())
	hud.update_character(current_character == rob)
	hud.update_lives(GameManager.lives)
	hud.show_intro(level, idx)
	hud.start_fade(-1, Callable())

func _clear_level() -> void:
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

func _create_platform(x: float, y: float, w: float, h: float, color: Color) -> void:
	var body := StaticBody2D.new()
	body.position = Vector2(x + w / 2.0, y + h / 2.0)

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size  = Vector2(w, h)
	shape.shape = rect
	body.add_child(shape)

	var visual := ColorRect.new()
	visual.size     = Vector2(w, h)
	visual.position = Vector2(-w / 2.0, -h / 2.0)
	visual.color    = color
	body.add_child(visual)

	var top_line := ColorRect.new()
	top_line.size     = Vector2(w, 3)
	top_line.position = Vector2(-w / 2.0, -h / 2.0)
	top_line.color    = color.lightened(0.3)
	body.add_child(top_line)

	add_child(body)
	level_nodes.append(body)

# ============================================================
# SAIDA DA FASE
# ============================================================

func _create_level_exit(pos: Vector2) -> void:
	var area := Area2D.new()
	area.position = pos
	area.name     = "LevelExit"

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size   = Vector2(40, 60)
	shape.shape = rect
	area.add_child(shape)

	var glow := ColorRect.new()
	glow.size     = Vector2(44, 64)
	glow.position = Vector2(-22, -32)
	glow.color    = Color(0.3, 1.0, 0.4, 0.25)
	area.add_child(glow)

	var visual := ColorRect.new()
	visual.size     = Vector2(40, 60)
	visual.position = Vector2(-20, -30)
	visual.color    = Color(0.2, 0.9, 0.3, 0.85)
	area.add_child(visual)

	var arrow := Label.new()
	arrow.text     = ">>>"
	arrow.position = Vector2(-18, -50)
	arrow.add_theme_font_size_override("font_size", 20)
	arrow.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	area.add_child(arrow)

	area.collision_layer = 0
	area.collision_mask  = 1
	area.body_entered.connect(_on_exit_body_entered)

	add_child(area)
	level_nodes.append(area)

func _on_exit_body_entered(body: Node) -> void:
	if body == current_character and not hud.fading:
		_complete_level()

# ============================================================
# LOOPY NPC
# ============================================================

func _create_loopy(pos: Vector2) -> void:
	loopy_body          = CharacterBody2D.new()
	loopy_body.position = pos

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size        = Vector2(24, 50)
	shape.shape      = rect
	shape.position   = Vector2(0, 25)
	loopy_body.add_child(shape)

	var visual := ColorRect.new()
	visual.size     = Vector2(24, 50)
	visual.position = Vector2(-12, 0)
	visual.color    = Color(0.9, 0.7, 0.2, 0.9)
	loopy_body.add_child(visual)

	var question := Label.new()
	question.text     = "?"
	question.position = Vector2(-6, -20)
	question.add_theme_font_size_override("font_size", 22)
	question.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	loopy_body.add_child(question)

	var name_lbl := Label.new()
	name_lbl.text     = "Loopy"
	name_lbl.position = Vector2(-20, -38)
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_lbl.add_theme_color_override("font_color", Color(1, 0.9, 0.4, 0.7))
	loopy_body.add_child(name_lbl)

	add_child(loopy_body)
	level_nodes.append(loopy_body)

func _update_loopy(delta: float) -> void:
	if not loopy_body or not is_instance_valid(loopy_body):
		return

	var dist := loopy_body.global_position.distance_to(current_character.global_position)
	if dist < 300:
		loopy_fleeing = true

	if loopy_fleeing:
		var dir := (loopy_end - loopy_body.global_position).normalized()
		loopy_body.velocity.x = dir.x * LOOPY_SPEED * 1.5
		if not loopy_body.is_on_floor():
			loopy_body.velocity += loopy_body.get_gravity() * delta
		loopy_body.move_and_slide()
		if loopy_body.global_position.distance_to(loopy_end) < 30:
			loopy_body.queue_free()
			loopy_body = null
	else:
		loopy_body.velocity.x = sin(Time.get_ticks_msec() * 0.002) * 30.0
		if not loopy_body.is_on_floor():
			loopy_body.velocity += loopy_body.get_gravity() * delta
		loopy_body.move_and_slide()

# ============================================================
# CAMERA
# ============================================================

func _update_camera(delta: float) -> void:
	if current_character and not current_character.is_dead:
		var target := current_character.global_position
		target.y = min(target.y, 400)
		camera.global_position = camera.global_position.lerp(target, 5.0 * delta)

# ============================================================
# TROCA DE PERSONAGEM
# ============================================================

func _switch_character() -> void:
	current_character = bog if current_character == rob else rob
	rob.set_active(current_character == rob)
	bog.set_active(current_character == bog)

	var tween := create_tween()
	tween.tween_property(current_character, "scale", Vector2(1.2, 0.8), 0.08)
	tween.tween_property(current_character, "scale", Vector2(0.9, 1.1), 0.08)
	tween.tween_property(current_character, "scale", Vector2(1.0, 1.0), 0.06)

	hud.update_character(current_character == rob)

# ============================================================
# MORTE (QUEDA)
# ============================================================

func _check_death() -> void:
	if hud.fading or hud.showing_intro:
		return

	if current_character.global_position.y > DEATH_Y:
		_on_player_died()
		return

	# Reposiciona o personagem inativo se cair
	var other := bog if current_character == rob else rob
	if other.global_position.y > DEATH_Y and not other.is_dead:
		other.global_position = current_character.global_position + Vector2(-40, -20)
		other.velocity        = Vector2.ZERO

func _on_player_died() -> void:
	if GameManager.lose_life():
		hud.update_lives(GameManager.lives)
		hud.start_fade(1, _reload_current_level)
	else:
		hud.start_fade(1, _go_to_menu)

func _reload_current_level() -> void:
	_load_level()

func _go_to_menu() -> void:
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# ============================================================
# COMPLETAR FASE
# ============================================================

func _complete_level() -> void:
	if GameManager.next_level():
		hud.start_fade(1, _load_next_level)
	else:
		_show_victory()

func _load_next_level() -> void:
	_setup_characters()
	_load_level()

func _show_victory() -> void:
	if victory_overlay:
		return

	victory_overlay       = ColorRect.new()
	victory_overlay.size  = Vector2(1152, 648)
	victory_overlay.color = Color(0.02, 0.04, 0.08, 0.90)

	var vbox := VBoxContainer.new()
	vbox.position = Vector2(200, 180)
	vbox.size     = Vector2(752, 320)
	vbox.add_theme_constant_override("separation", 18)

	var title := Label.new()
	title.text                 = "Você encontrou o Loopy!"
	title.size                 = Vector2(752, 0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 46)
	title.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	vbox.add_child(title)

	var sub := Label.new()
	sub.text                 = "Os três amigos estão juntos novamente."
	sub.size                 = Vector2(752, 0)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 22)
	sub.add_theme_color_override("font_color", Color(0.80, 0.80, 0.90))
	vbox.add_child(sub)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer)

	var hint := Label.new()
	hint.text                 = "Pressione  ESPAÇO  para voltar ao menu"
	hint.size                 = Vector2(752, 0)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 17)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.62))
	vbox.add_child(hint)

	victory_overlay.add_child(vbox)
	hud.add_child(victory_overlay)

	await get_tree().create_timer(0.5).timeout
	_wait_for_menu_input()

func _wait_for_menu_input() -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
			_go_to_menu()
			return

# ============================================================
# BACKGROUND
# ============================================================

func _create_background() -> void:
	bg_rect          = ColorRect.new()
	bg_rect.size     = Vector2(5000, 2000)
	bg_rect.position = Vector2(-1000, -500)
	bg_rect.color    = Color(0.15, 0.18, 0.28)
	bg_rect.z_index  = -100
	add_child(bg_rect)
