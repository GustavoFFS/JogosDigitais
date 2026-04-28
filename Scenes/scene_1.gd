extends Node2D

## Cena principal - Lost & Loopy
## Gerencia plataformas, personagens, camera, Loopy, checkpoints, hazards e transicoes.

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
const LOOPY_SPEED: float = 90.0

# Checkpoints
var checkpoint_rob: Vector2 = Vector2.ZERO
var checkpoint_bog: Vector2 = Vector2.ZERO
var has_checkpoint: bool    = false

# Background dinamico
var bg_rect: ColorRect

# Tela de vitoria
var victory_overlay: ColorRect = null

# Plataformas moveis
var _moving_platforms: Array = []

const DEATH_Y: float = 950.0

# Estrelas
var _stars_left_in_level: int = 0

# Blocos empurráveis (para mostrar dica de proximidade)
var _pushable_blocks: Array = []

# Pause overlay
var _pause_overlay: Control = null

# ============================================================
# INICIALIZACAO
# ============================================================

func _ready() -> void:
	_remove_old_static_bodies()
	_create_background()
	hud = GameHUD.new()
	add_child(hud)
	hud.pause_requested.connect(_toggle_pause)
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
	_update_moving_platforms(delta)
	_update_pushable_hints()
	hud.update_ability(rob.get_ability_ratio(), bog.get_ability_ratio())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_character") and not hud.showing_intro and not hud.fading:
		_switch_character()
	if event.is_action_pressed("pause") and not hud.showing_intro and victory_overlay == null:
		if hud.is_help_visible():
			hud._close_help()
		else:
			_toggle_pause()

# ============================================================
# PAUSE
# ============================================================

func _toggle_pause() -> void:
	if _pause_overlay and is_instance_valid(_pause_overlay):
		_close_pause()
	else:
		_open_pause()

func _open_pause() -> void:
	get_tree().paused = true

	_pause_overlay = Control.new()
	_pause_overlay.size = Vector2(1152, 648)
	_pause_overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	hud.add_child(_pause_overlay)

	var dim := ColorRect.new()
	dim.size  = Vector2(1152, 648)
	dim.color = Color(0, 0, 0, 0.72)
	_pause_overlay.add_child(dim)

	var box := ColorRect.new()
	box.size     = Vector2(440, 300)
	box.position = Vector2(356, 174)
	box.color    = Color(0.10, 0.12, 0.20, 0.98)
	_pause_overlay.add_child(box)

	var border := ColorRect.new()
	border.size     = Vector2(440, 4)
	border.position = Vector2(356, 174)
	border.color    = Color(0.30, 0.75, 1.0, 0.9)
	_pause_overlay.add_child(border)

	var title := Label.new()
	title.text     = "— PAUSA —"
	title.position = Vector2(356, 196)
	title.size     = Vector2(440, 44)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	_pause_overlay.add_child(title)

	var info := Label.new()
	info.text     = "★  Estrelas: %d / %d" % [GameManager.stars_collected, GameManager.stars_total_game]
	info.position = Vector2(356, 244)
	info.size     = Vector2(440, 24)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 16)
	info.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
	_pause_overlay.add_child(info)

	var btn_resume := Button.new()
	btn_resume.text = "Continuar"
	btn_resume.position = Vector2(416, 288)
	btn_resume.size     = Vector2(320, 46)
	btn_resume.add_theme_font_size_override("font_size", 20)
	btn_resume.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_resume.pressed.connect(_close_pause)
	_pause_overlay.add_child(btn_resume)

	var btn_menu := Button.new()
	btn_menu.text = "Voltar ao Menu"
	btn_menu.position = Vector2(416, 346)
	btn_menu.size     = Vector2(320, 46)
	btn_menu.add_theme_font_size_override("font_size", 20)
	btn_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_menu.pressed.connect(_quit_to_menu)
	_pause_overlay.add_child(btn_menu)

	var hint := Label.new()
	hint.text     = "ESC  para continuar"
	hint.position = Vector2(356, 414)
	hint.size     = Vector2(440, 24)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.62))
	_pause_overlay.add_child(hint)

func _close_pause() -> void:
	if _pause_overlay and is_instance_valid(_pause_overlay):
		_pause_overlay.queue_free()
	_pause_overlay = null
	get_tree().paused = false

func _quit_to_menu() -> void:
	get_tree().paused = false
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# ============================================================
# CARREGAMENTO DE FASE
# ============================================================

func _setup_characters() -> void:
	current_character = rob
	rob.set_active(true)
	bog.set_active(false)
	# Rob e Bog não colidem entre si (atravessam um ao outro)
	rob.add_collision_exception_with(bog)
	bog.add_collision_exception_with(rob)

func _load_level() -> void:
	_clear_level()

	var level := GameManager.get_current_level()
	var idx   := GameManager.current_level_index

	rob.apply_modifiers(level["modifiers"])
	bog.apply_modifiers(level["modifiers"])
	rob.revive()
	bog.revive()

	# Posicionar nos spawns (sobrescreve com checkpoint se existir)
	var spawn_r := Vector2(level["spawn_rob"][0], level["spawn_rob"][1])
	var spawn_b := Vector2(level["spawn_bog"][0], level["spawn_bog"][1])

	if has_checkpoint:
		rob.global_position = checkpoint_rob
		bog.global_position = checkpoint_bog
	else:
		rob.global_position = spawn_r
		bog.global_position = spawn_b

	rob.velocity = Vector2.ZERO
	bog.velocity = Vector2.ZERO

	# Geometria
	bg_rect.color = level["bg_color"]
	_create_scenery(idx)
	for p in level["platforms"]:
		_create_platform(p[0], p[1], p[2], p[3], level["platform_color"])
	
	# Plataformas moveis — adicione estas duas linhas abaixo
	for mp in level.get("moving_platforms", []):
		_spawn_moving_platform(mp, level["platform_color"])
		
	# Checkpoints e hazards
	for cp in level.get("checkpoints", []):
		_create_checkpoint(cp[0], cp[1])
	for h in level.get("hazards", []):
		_create_hazard(h[0], h[1], h[2], h[3])

	_create_level_exit(Vector2(level["exit_pos"][0], level["exit_pos"][1]))

	# Blocos empurráveis (só Bog consegue mover — can_push=true)
	for pb in level.get("pushable_blocks", []):
		_create_pushable_block(pb[0], pb[1], pb[2], pb[3])

	# Estrelas coletáveis da fase (pula as já coletadas nesta partida)
	var stars: Array = level.get("stars", [])
	GameManager.stars_in_level = stars.size()
	_stars_left_in_level = stars.size()
	for i in range(stars.size()):
		if GameManager.is_star_collected(idx, i):
			_stars_left_in_level -= 1
			continue
		_create_star(stars[i][0], stars[i][1], idx, i)
	hud.update_stars(GameManager.stars_collected, GameManager.stars_total_game)

	loopy_start = Vector2(level["loopy_start"][0], level["loopy_start"][1])
	loopy_end   = Vector2(level["loopy_end"][0],   level["loopy_end"][1])
	_create_loopy(loopy_start)

	camera.global_position = current_character.global_position
	hud.update_level_info(level, idx, GameManager.get_level_count())
	hud.update_character(current_character == rob)
	hud.update_deaths(GameManager.deaths)
	hud.show_intro(level, idx)
	hud.start_fade(-1, Callable())

func _clear_level() -> void:
	_moving_platforms.clear()
	_pushable_blocks.clear()
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
	rect.size   = Vector2(w, h)
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

func _spawn_moving_platform(mp: Dictionary, color: Color) -> void:
	var w: float = mp["w"]
	var h: float = mp["h"]

	var body := AnimatableBody2D.new()
	body.sync_to_physics = true
	body.position = Vector2(mp["x_min"] + w / 2.0, mp["y"])

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size   = Vector2(w, h)
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
	_moving_platforms.append({
		"node":  body,
		"x_min": mp["x_min"] + w / 2.0,
		"x_max": mp["x_max"] + w / 2.0,
		"speed": mp["speed"],
		"dir":   1.0
	})

func _update_moving_platforms(delta: float) -> void:
	for mp in _moving_platforms:
		if not is_instance_valid(mp["node"]):
			continue
		var movement :float= mp["speed"] * mp["dir"] * delta
		mp["node"].move_and_collide(Vector2(movement, 0))
		
		var px :float = mp["node"].position.x
		if px >= mp["x_max"]:
			mp["dir"] = -1.0
		elif px <= mp["x_min"]:
			mp["dir"] = 1.0			
# ============================================================
# CHECKPOINTS
# ============================================================

func _create_checkpoint(x: float, y: float) -> void:
	var area := Area2D.new()
	area.position = Vector2(x, y)
	area.set_meta("activated", false)

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size   = Vector2(28, 64)
	shape.shape = rect
	area.add_child(shape)

	# Haste da bandeira
	var pole := ColorRect.new()
	pole.size     = Vector2(4, 58)
	pole.position = Vector2(-2, -62)
	pole.color    = Color(0.75, 0.75, 0.78)
	area.add_child(pole)

	# Bandeira (amarela = inativa)
	var flag := ColorRect.new()
	flag.size     = Vector2(22, 14)
	flag.position = Vector2(2, -62)
	flag.color    = Color(0.92, 0.82, 0.12)
	flag.name     = "Flag"
	area.add_child(flag)

	# "CP"
	var lbl := Label.new()
	lbl.text     = "CP"
	lbl.position = Vector2(-11, -80)
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.92, 0.82, 0.12, 0.85))
	area.add_child(lbl)

	area.collision_layer = 0
	area.collision_mask  = 1
	area.body_entered.connect(_on_checkpoint_entered.bind(area))

	add_child(area)
	level_nodes.append(area)

func _on_checkpoint_entered(body: Node, area: Area2D) -> void:
	if body != rob and body != bog:
		return
	if area.get_meta("activated", false):
		return
	area.set_meta("activated", true)

	# Salvar posicoes
	checkpoint_rob = rob.global_position
	checkpoint_bog = bog.global_position
	has_checkpoint = true

	# Bandeira vira verde
	var flag := area.get_node_or_null("Flag")
	if flag:
		flag.color = Color(0.20, 0.90, 0.35)

	hud.show_checkpoint_notification()

# ============================================================
# HAZARDS (ZONAS DE MORTE)
# ============================================================

func _create_hazard(x: float, y: float, w: float, h: float) -> void:
	var area := Area2D.new()
	area.position = Vector2(x + w / 2.0, y + h / 2.0)

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size   = Vector2(w, h)
	shape.shape = rect
	area.add_child(shape)

	# Fundo vermelho
	var visual := ColorRect.new()
	visual.size     = Vector2(w, h)
	visual.position = Vector2(-w / 2.0, -h / 2.0)
	visual.color    = Color(0.75, 0.10, 0.10, 0.82)
	area.add_child(visual)

	# Espinhos visuais (triângulos simulados com labels)
	var n_spikes := int(w / 16)
	for i in range(n_spikes):
		var sp := Label.new()
		sp.text     = "▲"
		sp.position = Vector2(-w / 2.0 + i * 16, -h / 2.0 - 4)
		sp.add_theme_font_size_override("font_size", 13)
		sp.add_theme_color_override("font_color", Color(1.0, 0.30, 0.30))
		area.add_child(sp)

	area.collision_layer = 0
	area.collision_mask  = 1
	area.body_entered.connect(_on_hazard_entered)

	add_child(area)
	level_nodes.append(area)

func _on_hazard_entered(body: Node) -> void:
	if body == current_character and not hud.fading and not hud.showing_intro:
		_on_player_died()

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
	glow.size     = Vector2(48, 68)
	glow.position = Vector2(-24, -34)
	glow.color    = Color(0.3, 1.0, 0.4, 0.22)
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
# BLOCOS EMPURRÁVEIS (apenas Bog move)
# ============================================================

func _create_pushable_block(x: float, y: float, w: float, h: float) -> void:
	var body := RigidBody2D.new()
	body.add_to_group("pushable")
	body.position      = Vector2(x + w / 2.0, y + h / 2.0)
	body.mass          = 1.0
	body.gravity_scale = 1.2
	body.lock_rotation = true
	body.linear_damp   = 2.5
	body.angular_damp  = 10.0
	body.collision_layer = 1
	body.collision_mask  = 1

	# Sem atrito com o chão para o empurrão funcionar
	var pmat := PhysicsMaterial.new()
	pmat.friction = 0.0
	pmat.bounce   = 0.0
	body.physics_material_override = pmat

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size   = Vector2(w, h)
	shape.shape = rect
	body.add_child(shape)

	# Caixa de madeira (tons quentes)
	var visual := ColorRect.new()
	visual.size     = Vector2(w, h)
	visual.position = Vector2(-w / 2.0, -h / 2.0)
	visual.color    = Color(0.58, 0.38, 0.22)
	body.add_child(visual)

	# Borda clara em cima e escura em baixo (efeito de madeira)
	var top := ColorRect.new()
	top.size     = Vector2(w, 4)
	top.position = Vector2(-w / 2.0, -h / 2.0)
	top.color    = Color(0.78, 0.56, 0.32)
	body.add_child(top)

	var bot := ColorRect.new()
	bot.size     = Vector2(w, 3)
	bot.position = Vector2(-w / 2.0, h / 2.0 - 3)
	bot.color    = Color(0.30, 0.18, 0.10)
	body.add_child(bot)

	# Tira diagonal (madeira)
	var stripe := ColorRect.new()
	stripe.size     = Vector2(w, 2)
	stripe.position = Vector2(-w / 2.0, 0)
	stripe.color    = Color(0.42, 0.26, 0.14)
	body.add_child(stripe)

	# Ícone permanente "BOG" sobre a caixa (sempre visível)
	var tag := Label.new()
	tag.text     = "BOG"
	tag.position = Vector2(-w / 2.0, -h / 2.0 - 20)
	tag.size     = Vector2(w, 18)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.add_theme_font_size_override("font_size", 12)
	tag.add_theme_color_override("font_color", Color(1.0, 0.62, 0.26))
	body.add_child(tag)

	# Dica dinâmica (mostrada quando algum personagem está perto)
	var hint := Label.new()
	hint.text     = ""
	hint.name     = "Hint"
	hint.position = Vector2(-160, -h / 2.0 - 50)
	hint.size     = Vector2(320, 24)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30))
	hint.modulate.a = 0.0
	body.add_child(hint)

	add_child(body)
	level_nodes.append(body)
	_pushable_blocks.append(body)

func _update_pushable_hints() -> void:
	if not current_character or victory_overlay != null:
		return
	for block in _pushable_blocks:
		if not is_instance_valid(block):
			continue
		var hint: Label = block.get_node_or_null("Hint")
		if hint == null:
			continue
		var dist := block.global_position.distance_to(current_character.global_position)
		if dist > 160.0:
			hint.modulate.a = lerp(hint.modulate.a, 0.0, 0.15)
			continue

		if current_character == bog:
			hint.text = "↔  Caminhe contra a caixa para empurrar"
			hint.add_theme_color_override("font_color", Color(0.55, 1.0, 0.55))
		else:
			hint.text = "Troque para o BOG  [TAB]  para empurrar"
			hint.add_theme_color_override("font_color", Color(1.0, 0.78, 0.30))
		hint.modulate.a = lerp(hint.modulate.a, 1.0, 0.20)

# ============================================================
# ESTRELAS COLETÁVEIS
# ============================================================

func _create_star(x: float, y: float, level_idx: int, star_idx: int) -> void:
	var area := Area2D.new()
	area.position = Vector2(x, y)
	area.name     = "Star"
	area.set_meta("level_idx", level_idx)
	area.set_meta("star_idx",  star_idx)

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size   = Vector2(30, 30)
	shape.shape = rect
	area.add_child(shape)

	# Visual: estrela dourada feita de ColorRects (losango + centro)
	var star_visual := Node2D.new()
	area.add_child(star_visual)
	var gold    := Color(1.0, 0.88, 0.30)
	var gold_hi := Color(1.0, 0.96, 0.55)
	for v in [Vector2(-3, -12), Vector2(-3, 6), Vector2(-12, -3), Vector2(6, -3)]:
		var arm := ColorRect.new()
		arm.size     = Vector2(6, 6)
		arm.position = v
		arm.color    = gold
		star_visual.add_child(arm)
	var body := ColorRect.new()
	body.size     = Vector2(12, 12)
	body.position = Vector2(-6, -6)
	body.color    = gold_hi
	star_visual.add_child(body)
	var inner := ColorRect.new()
	inner.size     = Vector2(6, 6)
	inner.position = Vector2(-3, -3)
	inner.color    = Color(1.0, 1.0, 0.85)
	star_visual.add_child(inner)

	# Brilho ao redor
	var glow := ColorRect.new()
	glow.size     = Vector2(36, 36)
	glow.position = Vector2(-18, -18)
	glow.color    = Color(1.0, 0.88, 0.30, 0.18)
	star_visual.add_child(glow)
	star_visual.move_child(glow, 0)

	# Flutuação suave
	var tw := create_tween().set_loops()
	tw.tween_property(star_visual, "position:y", -6.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(star_visual, "position:y",  0.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	area.collision_layer = 0
	area.collision_mask  = 1
	area.body_entered.connect(_on_star_body_entered.bind(area))

	add_child(area)
	level_nodes.append(area)

func _on_star_body_entered(body: Node, area: Area2D) -> void:
	if body != current_character and body != rob and body != bog:
		return
	if not is_instance_valid(area):
		return
	var li: int = area.get_meta("level_idx")
	var si: int = area.get_meta("star_idx")
	if GameManager.is_star_collected(li, si):
		return
	GameManager.collect_star(li, si)
	_stars_left_in_level -= 1
	hud.update_stars(GameManager.stars_collected, GameManager.stars_total_game)
	hud.flash_star()

	# Animação de coleta: escala/fade antes de remover
	var tw := create_tween().set_parallel(true)
	tw.tween_property(area, "scale", Vector2(2.0, 2.0), 0.25)
	tw.tween_property(area, "modulate:a", 0.0, 0.25)
	tw.chain().tween_callback(area.queue_free)
	level_nodes.erase(area)

# ============================================================
# LOOPY NPC
# ============================================================

func _create_loopy(pos: Vector2) -> void:
	loopy_body          = CharacterBody2D.new()
	loopy_body.position = pos

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size      = Vector2(24, 50)
	shape.shape    = rect
	shape.position = Vector2(0, 25)
	loopy_body.add_child(shape)

	var visual := ColorRect.new()
	visual.size     = Vector2(24, 50)
	visual.position = Vector2(-12, 0)
	visual.color    = Color(0.9, 0.7, 0.2, 0.9)
	loopy_body.add_child(visual)

	var question := Label.new()
	question.text     = "?"
	question.position = Vector2(-6, -22)
	question.add_theme_font_size_override("font_size", 22)
	question.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	loopy_body.add_child(question)

	var name_lbl := Label.new()
	name_lbl.text     = "Loopy"
	name_lbl.position = Vector2(-20, -40)
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_lbl.add_theme_color_override("font_color", Color(1, 0.9, 0.4, 0.7))
	loopy_body.add_child(name_lbl)

	add_child(loopy_body)
	level_nodes.append(loopy_body)

func _update_loopy(delta: float) -> void:
	if not loopy_body or not is_instance_valid(loopy_body):
		return

	var dist := loopy_body.global_position.distance_to(current_character.global_position)
	if dist < 320:
		loopy_fleeing = true

	if loopy_fleeing:
		var dir := (loopy_end - loopy_body.global_position).normalized()
		loopy_body.velocity.x = dir.x * LOOPY_SPEED * 1.6
		if not loopy_body.is_on_floor():
			loopy_body.velocity += loopy_body.get_gravity() * delta
		loopy_body.move_and_slide()
		if loopy_body.global_position.distance_to(loopy_end) < 30:
			loopy_body.queue_free()
			loopy_body = null
	else:
		loopy_body.velocity.x = sin(Time.get_ticks_msec() * 0.002) * 28.0
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
# MORTE
# ============================================================

func _check_death() -> void:
	if hud.fading or hud.showing_intro:
		return

	if current_character.global_position.y > DEATH_Y:
		_on_player_died()
		return

	var other := bog if current_character == rob else rob
	if other.global_position.y > DEATH_Y and not other.is_dead:
		other.global_position = current_character.global_position + Vector2(-40, -20)
		other.velocity        = Vector2.ZERO

func _on_player_died() -> void:
	GameManager.register_death()
	hud.update_deaths(GameManager.deaths)
	hud.start_fade(1, _reload_current_level)

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
	has_checkpoint = false
	_setup_characters()
	_load_level()

# ============================================================
# VITORIA - LOOPY VOLTA A CONSCIENCIA
# ============================================================

func _show_victory() -> void:
	if victory_overlay:
		return

	victory_overlay       = ColorRect.new()
	victory_overlay.size  = Vector2(1152, 648)
	victory_overlay.color = Color(0.02, 0.04, 0.08, 0.94)
	hud.add_child(victory_overlay)

	_run_victory_sequence()

func _add_victory_label(txt: String, y: float, fs: int, col: Color) -> void:
	var lbl := Label.new()
	lbl.text                 = txt
	lbl.position            = Vector2(80, y)
	lbl.size                 = Vector2(992, 58)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", fs)
	lbl.add_theme_color_override("font_color", col)
	lbl.modulate.a = 0.0
	victory_overlay.add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "modulate:a", 1.0, 0.55)

func _run_victory_sequence() -> void:
	# Calcula o "rank" do final com base nas estrelas coletadas.
	# tier: 0=básico, 1=bom, 2=brilhante, 3=lendário (100%).
	var total: int = GameManager.stars_total_game
	var got:   int = GameManager.stars_collected
	var pct:   float = 0.0 if total == 0 else float(got) / total
	var tier:  int = 0
	if pct >= 1.0:        tier = 3
	elif pct >= 0.75:     tier = 2
	elif pct >= 0.5:      tier = 1

	_add_victory_sky(tier)

	_add_victory_label("Você alcançou o Loopy!", 18, 38, Color(0.28, 1.0, 0.42))
	await get_tree().create_timer(1.4).timeout

	_add_victory_label("Loopy para no meio da rua...", 80, 20, Color(0.78, 0.78, 0.90))
	await get_tree().create_timer(1.1).timeout

	_add_victory_label("Ele olha ao redor, confuso.", 108, 20, Color(0.78, 0.78, 0.90))
	await get_tree().create_timer(1.1).timeout

	_add_victory_label("Seus olhos focam lentamente...", 136, 20, Color(0.78, 0.78, 0.90))
	await get_tree().create_timer(1.3).timeout

	_add_victory_label("— Rob?  Bog?  O que aconteceu?  Onde eu estava? —",
					   166, 20, Color(1.0, 0.92, 0.38))
	await get_tree().create_timer(1.5).timeout

	# Frase específica do tier (só nos finais melhores Loopy reage diferente)
	match tier:
		3:
			_add_victory_label("— Vocês me trouxeram TODAS as estrelas?! Que jornada lendária! —",
							   200, 17, Color(1.0, 0.88, 0.30))
		2:
			_add_victory_label("— Olha quantas estrelas! Vocês brilharam de verdade. —",
							   200, 17, Color(0.95, 0.85, 0.45))
		1:
			_add_victory_label("— Voltaram com algumas estrelas... bom resgate, amigos. —",
							   200, 17, Color(0.85, 0.85, 0.95))
		_:
			_add_victory_label("O efeito do chá foi embora.",
							   200, 17, Color(0.70, 0.70, 0.82))
	await get_tree().create_timer(1.4).timeout

	_add_reunion_scene(tier)
	await get_tree().create_timer(0.8).timeout

	# Estatísticas e título do final
	var stats_msg := "★  %d / %d   ·   💀  %d morte%s" % [
		got, total, GameManager.deaths,
		"" if GameManager.deaths == 1 else "s"
	]
	_add_victory_label(stats_msg, 588, 18, _tier_color(tier))
	await get_tree().create_timer(0.8).timeout

	_add_victory_label(_tier_title(tier), 612, 24, _tier_color(tier))
	await get_tree().create_timer(0.9).timeout

	_add_victory_label("Pressione  ESPAÇO  para voltar ao menu",
					   636, 13, Color(0.55, 0.55, 0.65))

	await get_tree().create_timer(0.4).timeout
	_wait_for_menu_input()

func _tier_title(tier: int) -> String:
	match tier:
		3: return "★  FINAL LENDÁRIO  ·  Os três heróis brilham para sempre  ★"
		2: return "✦  Final Brilhante  ·  Um resgate cheio de glória"
		1: return "Bom resgate!  Os três amigos estão juntos novamente"
		_: return "Resgate concluído  ·  Loopy está em casa"
	return ""

func _tier_color(tier: int) -> Color:
	match tier:
		3: return Color(1.0, 0.85, 0.25)   # dourado
		2: return Color(1.0, 0.92, 0.55)   # dourado claro
		1: return Color(0.85, 0.92, 1.0)   # prateado/azul claro
		_: return Color(0.85, 0.85, 0.95)
	return Color.WHITE

# ============================================================
# CENA VISUAL DO REENCONTRO (os 3 amigos juntos)
# ============================================================

func _add_victory_sky(tier: int = 0) -> void:
	# Cores do céu mudam conforme o tier (mais brilho/dourado nos finais melhores)
	var sky_col   := Color(0.18, 0.12, 0.28)
	var dusk_col  := Color(0.85, 0.45, 0.30)
	var glow_col  := Color(0.98, 0.72, 0.35)
	if tier == 1:
		dusk_col = Color(0.90, 0.55, 0.30)
		glow_col = Color(1.00, 0.78, 0.40)
	elif tier == 2:
		sky_col  = Color(0.22, 0.14, 0.34)
		dusk_col = Color(1.00, 0.62, 0.30)
		glow_col = Color(1.00, 0.86, 0.45)
	elif tier == 3:
		sky_col  = Color(0.30, 0.18, 0.45)
		dusk_col = Color(1.00, 0.70, 0.30)
		glow_col = Color(1.00, 0.94, 0.55)

	var sky := ColorRect.new()
	sky.position = Vector2(0, 230)
	sky.size     = Vector2(1152, 80)
	sky.color    = sky_col
	victory_overlay.add_child(sky)
	var dusk := ColorRect.new()
	dusk.position = Vector2(0, 310)
	dusk.size     = Vector2(1152, 80)
	dusk.color    = dusk_col
	victory_overlay.add_child(dusk)
	var glow := ColorRect.new()
	glow.position = Vector2(0, 390)
	glow.size     = Vector2(1152, 80)
	glow.color    = glow_col
	victory_overlay.add_child(glow)

	# No tier 3 (lendário), adiciona estrelas brilhando no céu
	if tier == 3:
		for i in range(40):
			var sx: float = 30.0 + (i * 67) % 1100
			var sy: float = 240.0 + (i * 31) % 70
			var twk := ColorRect.new()
			twk.position = Vector2(sx, sy)
			twk.size     = Vector2(3, 3)
			twk.color    = Color(1.0, 0.95, 0.70)
			victory_overlay.add_child(twk)
			var tw := create_tween().set_loops()
			tw.tween_property(twk, "modulate:a", 0.3, 0.6 + (i % 5) * 0.15)
			tw.tween_property(twk, "modulate:a", 1.0, 0.6 + (i % 5) * 0.15)

func _add_reunion_scene(tier: int = 0) -> void:
	var scene := Control.new()
	scene.position = Vector2(0, 0)
	scene.size     = Vector2(1152, 648)
	scene.modulate.a = 0.0
	victory_overlay.add_child(scene)

	# Auréola dourada nos finais melhores (tier 2+)
	if tier >= 2:
		var halo := ColorRect.new()
		halo.position = Vector2(388, 380)
		halo.size     = Vector2(376, 220)
		halo.color    = Color(1.0, 0.88, 0.30, 0.18 if tier == 2 else 0.30)
		scene.add_child(halo)

	# Edifícios ao fundo (silhuetas com janelas acesas)
	for i in range(9):
		var bx: float = 40.0 + i * 130.0
		var bh: float = 60.0 + ((i * 37) % 50)
		_v_rect(scene, bx, 430.0 - bh, 110.0, bh, Color(0.18, 0.14, 0.26))
		for jy in range(3):
			for jx in range(3):
				if (i + jx + jy) % 3 == 0:
					_v_rect(scene, bx + 12.0 + jx * 30, 430.0 - bh + 10.0 + jy * 16,
							10.0, 8.0, Color(1.0, 0.85, 0.45, 0.9))

	# Sol pôr-do-sol
	_v_rect(scene, 540.0, 345.0, 72.0, 72.0, Color(1.0, 0.78, 0.35))
	_v_rect(scene, 510.0, 395.0, 132.0, 26.0, Color(1.0, 0.58, 0.28, 0.55))

	# Chão
	_v_rect(scene, 0.0, 470.0, 1152.0, 115.0, Color(0.22, 0.16, 0.14))
	_v_rect(scene, 0.0, 470.0, 1152.0, 4.0,   Color(0.12, 0.09, 0.06))
	_v_rect(scene, 0.0, 540.0, 1152.0, 2.0, Color(0.35, 0.28, 0.20))

	# Título centralizado acima do céu — varia conforme o tier
	var title := "— REENCONTRO —"
	var title_col := Color(1.0, 0.90, 0.50)
	if tier == 3:
		title = "★  REENCONTRO LENDÁRIO  ★"
		title_col = Color(1.0, 0.92, 0.40)
	elif tier == 2:
		title = "✦  REENCONTRO BRILHANTE  ✦"
		title_col = Color(1.0, 0.88, 0.50)
	elif tier == 1:
		title = "—  BOM REENCONTRO  —"
	_v_label(scene, title, 0.0, 255.0, 24, title_col, true)

	# Personagens em y=570 (acima dos labels em y=588)
	_add_character_sprite(scene, "res://Assets/Characters/Main_2/Idle.png", 420.0, 570.0, 1.6)
	_draw_loopy_full(scene, 576.0, 570.0, 1.3)
	_add_character_sprite(scene, "res://Assets/Characters/Main_1/Idle.png", 730.0, 570.0, 1.6)

	# Corações acima das cabeças (entre y=300 e y=420)
	_add_heart(scene, 400.0, 340.0)
	_add_heart(scene, 750.0, 345.0)
	_v_label(scene, "♪", 485.0, 335.0, 30, Color(1.0, 0.85, 0.45))
	_v_label(scene, "♫", 650.0, 340.0, 30, Color(1.0, 0.75, 0.35))

	var tw := create_tween()
	tw.tween_property(scene, "modulate:a", 1.0, 0.85)

## Carrega spritesheet 16-frames e mostra o frame 0 como sprite estático.
func _add_character_sprite(parent: Node, path: String, feet_x: float, feet_y: float, scl: float) -> void:
	var sprite := Sprite2D.new()
	var tex: Texture2D = load(path)
	if tex == null:
		return
	sprite.texture  = tex
	sprite.hframes  = 16
	sprite.frame    = 0
	sprite.scale    = Vector2(scl, scl)
	var frame_h := tex.get_height()
	sprite.position = Vector2(feet_x, feet_y - (frame_h * scl) * 0.5)
	parent.add_child(sprite)

func _v_rect(parent: Node, x: float, y: float, w: float, h: float, col: Color) -> void:
	var r := ColorRect.new()
	r.position = Vector2(x, y)
	r.size     = Vector2(w, h)
	r.color    = col
	parent.add_child(r)

func _v_label(parent: Node, txt: String, x: float, y: float, fs: int, col: Color,
			  center_full: bool = false) -> void:
	var l := Label.new()
	l.text     = txt
	l.position = Vector2(x, y)
	l.size     = Vector2(1152 if center_full else 60, 50)
	if center_full:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", col)
	parent.add_child(l)

func _add_heart(parent: Node, x: float, y: float) -> void:
	var red := Color(1.0, 0.35, 0.45)
	_v_rect(parent, x,      y,      10, 14, red)
	_v_rect(parent, x + 12, y,      10, 14, red)
	_v_rect(parent, x + 2,  y + 12, 18, 8,  red)
	_v_rect(parent, x + 6,  y + 18, 10, 6,  red)

# ---- Personagens ----
#
# Coord system: cx = centro horizontal, cy = pés. `dy` = distância do
# TOPO do retângulo acima dos pés (maior = mais alto na tela).

func _pr(parent: Node, cx: float, cy: float, s: float,
		 dx: float, dy: float, w: float, h: float, col: Color) -> void:
	var r := ColorRect.new()
	r.position = Vector2(cx + dx * s, cy - dy * s)
	r.size     = Vector2(w * s, h * s)
	r.color    = col
	parent.add_child(r)

func _draw_loopy_full(parent: Node, cx: float, cy: float, s: float) -> void:
	var skin   := Color(0.96, 0.82, 0.66)
	var hair   := Color(0.42, 0.26, 0.14)
	var beard  := Color(0.52, 0.36, 0.20)
	var beanie := Color(0.30, 0.55, 0.28)
	var leaf   := Color(0.55, 0.78, 0.30)
	var hood   := Color(0.95, 0.74, 0.22)
	var cape   := Color(0.44, 0.24, 0.52)
	var jeans  := Color(0.30, 0.40, 0.62)
	var shoe   := Color(0.36, 0.60, 0.32)
	var staff  := Color(0.34, 0.20, 0.10)
	var cup    := Color(0.96, 0.94, 0.88)
	var tea    := Color(0.50, 0.30, 0.16)
	var duck   := Color(1.00, 0.82, 0.18)
	var beak   := Color(0.96, 0.56, 0.14)
	var dark   := Color(0.10, 0.08, 0.06)

	_pr(parent, cx, cy, s, -30,  95, 60, 75, cape)
	_pr(parent, cx, cy, s, -14,  9, 12, 9, shoe)
	_pr(parent, cx, cy, s,   2,  9, 12, 9, shoe)
	_pr(parent, cx, cy, s, -14,  2, 12, 2, dark)
	_pr(parent, cx, cy, s,   2,  2, 12, 2, dark)
	_pr(parent, cx, cy, s, -12, 38, 10, 29, jeans)
	_pr(parent, cx, cy, s,   2, 38, 10, 29, jeans)
	_pr(parent, cx, cy, s, -18, 72, 36, 34, hood)
	_pr(parent, cx, cy, s, -18, 40, 36, 3, Color(hood.r * 0.7, hood.g * 0.6, hood.b * 0.4))
	_pr(parent, cx, cy, s, -24, 65, 7, 22, hood)
	_pr(parent, cx, cy, s, -36, 55, 12, 8, duck)
	_pr(parent, cx, cy, s, -30, 62,  8, 7, duck)
	_pr(parent, cx, cy, s, -38, 60,  3, 2, dark)
	_pr(parent, cx, cy, s, -42, 58,  4, 3, beak)
	_pr(parent, cx, cy, s,  17, 65, 7, 22, hood)
	_pr(parent, cx, cy, s,  16, 55, 10, 45, cape)
	_pr(parent, cx, cy, s, -12, 100, 24, 26, skin)
	_pr(parent, cx, cy, s, -12, 84, 24, 13, beard)
	_pr(parent, cx, cy, s, -10, 75, 20,  5, beard)
	_pr(parent, cx, cy, s, -14, 98, 4, 12, hair)
	_pr(parent, cx, cy, s,  10, 98, 4, 12, hair)
	_pr(parent, cx, cy, s, -7, 93, 3, 3, dark)
	_pr(parent, cx, cy, s,  3, 93, 3, 3, dark)
	_pr(parent, cx, cy, s, -2, 88, 4, 4, Color(skin.r * 0.85, skin.g * 0.72, skin.b * 0.60))
	_pr(parent, cx, cy, s, -4, 82, 8, 1.5, dark)
	_pr(parent, cx, cy, s, -15, 118, 30, 14, beanie)
	_pr(parent, cx, cy, s, -14, 106, 28, 3, Color(beanie.r * 0.65, beanie.g * 0.65, beanie.b * 0.60))
	_pr(parent, cx, cy, s,  2, 125, 7, 6, leaf)
	_pr(parent, cx, cy, s,  6, 130, 4, 4, leaf)
	_pr(parent, cx, cy, s, 22, 122, 4, 70, staff)
	_pr(parent, cx, cy, s, 18, 134, 14, 11, cup)
	_pr(parent, cx, cy, s, 20, 132,  9,  4, tea)
	_pr(parent, cx, cy, s, 32, 130,  3,  6, cup)

func _draw_rob_sil(parent: Node, cx: float, cy: float, s: float) -> void:
	var skin  := Color(0.98, 0.84, 0.70)
	var shirt := Color(0.30, 0.65, 1.00)
	var pants := Color(0.22, 0.28, 0.42)
	var shoe  := Color(0.14, 0.14, 0.18)
	var hair  := Color(0.22, 0.16, 0.10)
	var dark  := Color(0.05, 0.05, 0.05)
	# Pés
	_pr(parent, cx, cy, s, -12,  8,  10, 8, shoe)
	_pr(parent, cx, cy, s,   2,  8,  10, 8, shoe)
	# Calça
	_pr(parent, cx, cy, s, -10, 32, 9, 24, pants)
	_pr(parent, cx, cy, s,   1, 32, 9, 24, pants)
	# Camisa
	_pr(parent, cx, cy, s, -14, 60, 28, 28, shirt)
	# Braços
	_pr(parent, cx, cy, s, -18, 55, 4, 22, skin)
	_pr(parent, cx, cy, s,  14, 55, 4, 22, skin)
	# Cabeça
	_pr(parent, cx, cy, s,  -9, 80, 18, 20, skin)
	# Cabelo
	_pr(parent, cx, cy, s, -10, 84, 20, 7, hair)
	# Olhos
	_pr(parent, cx, cy, s, -5, 74, 2, 2, dark)
	_pr(parent, cx, cy, s,  3, 74, 2, 2, dark)
	# Sorriso
	_pr(parent, cx, cy, s, -3, 68, 6, 1.5, Color(0.6, 0.2, 0.2))
	_v_label(parent, "Rob", cx - 24.0, cy + 14.0, 14, Color(0.55, 0.88, 1.0))

func _draw_bog_sil(parent: Node, cx: float, cy: float, s: float) -> void:
	var skin  := Color(0.98, 0.78, 0.62)
	var shirt := Color(1.00, 0.55, 0.20)
	var pants := Color(0.36, 0.24, 0.14)
	var shoe  := Color(0.18, 0.14, 0.10)
	var hair  := Color(0.10, 0.08, 0.06)
	var dark  := Color(0.05, 0.05, 0.05)
	# Pés (mais largos)
	_pr(parent, cx, cy, s, -14,  8,  12, 8, shoe)
	_pr(parent, cx, cy, s,   2,  8,  12, 8, shoe)
	# Calça
	_pr(parent, cx, cy, s, -12, 34, 11, 26, pants)
	_pr(parent, cx, cy, s,   1, 34, 11, 26, pants)
	# Camisa (mais largo)
	_pr(parent, cx, cy, s, -18, 64, 36, 30, shirt)
	# Braços
	_pr(parent, cx, cy, s, -22, 58, 4, 22, skin)
	_pr(parent, cx, cy, s,  18, 58, 4, 22, skin)
	# Cabeça
	_pr(parent, cx, cy, s, -11, 86, 22, 22, skin)
	_pr(parent, cx, cy, s, -12, 90, 24, 7, hair)
	_pr(parent, cx, cy, s, -6, 80, 2, 2, dark)
	_pr(parent, cx, cy, s,  4, 80, 2, 2, dark)
	_pr(parent, cx, cy, s, -3, 72, 6, 1.5, Color(0.5, 0.2, 0.2))
	_v_label(parent, "Bog", cx - 24.0, cy + 14.0, 14, Color(1.0, 0.65, 0.30))

func _wait_for_menu_input() -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
			_go_to_menu()
			return

# ============================================================
# CENARIO URBANO DE FUNDO
# ============================================================

func _create_scenery(idx: int) -> void:
	const LEVEL_W := 3600.0

	# Paletas de edificios por fase
	var palettes: Array = [
		[Color(0.52, 0.60, 0.72), Color(0.76, 0.46, 0.30), Color(0.82, 0.74, 0.58)],  # ruas - dia
		[Color(0.48, 0.62, 0.80), Color(0.60, 0.78, 0.90), Color(0.44, 0.60, 0.74)],  # praca - gelo
		[Color(0.30, 0.24, 0.20), Color(0.24, 0.18, 0.14), Color(0.38, 0.28, 0.22)],  # telhados - noite
		[Color(0.20, 0.20, 0.18), Color(0.16, 0.16, 0.14), Color(0.24, 0.24, 0.20)],  # becos - escuro
		[Color(0.62, 0.40, 0.22), Color(0.50, 0.32, 0.18), Color(0.70, 0.48, 0.26)],  # final - por do sol
	]
	var palette: Array = palettes[clamp(idx, 0, palettes.size() - 1)]

	# Cor do ceu por fase
	var sky_colors: Array = [
		Color(0.52, 0.76, 0.94),  # azul dia
		Color(0.44, 0.68, 0.88),  # azul frio
		Color(0.10, 0.08, 0.18),  # noite
		Color(0.07, 0.07, 0.10),  # beco escuro
		Color(0.68, 0.38, 0.14),  # laranja poente
	]
	var sky_col: Color = sky_colors[clamp(idx, 0, sky_colors.size() - 1)]

	# Ceu
	var sky := ColorRect.new()
	sky.position = Vector2(-600, -500)
	sky.size     = Vector2(LEVEL_W + 1200, 1200)
	sky.color    = sky_col
	sky.z_index  = -80
	add_child(sky)
	level_nodes.append(sky)

	# Nuvens (fases ao ar livre)
	if idx <= 1:
		var cx_arr := [-200.0, 380.0, 820.0, 1320.0, 1900.0, 2480.0, 3060.0]
		var cy_arr := [60.0, 90.0, 45.0, 110.0, 70.0, 95.0, 55.0]
		for ci in range(cx_arr.size()):
			var cloud := ColorRect.new()
			cloud.position = Vector2(cx_arr[ci], cy_arr[ci])
			cloud.size     = Vector2(110 + (ci % 3) * 38, 28 + (ci % 2) * 14)
			cloud.color    = Color(1.0, 1.0, 1.0, 0.82)
			cloud.z_index  = -72
			add_child(cloud)
			level_nodes.append(cloud)

	# Edificios de fundo
	var bx       := -400.0
	var b_idx    := 0
	var win_col  := Color(0.96, 0.88, 0.52, 0.70)
	if idx == 3:
		win_col = Color(0.32, 0.28, 0.10, 0.45)
	elif idx == 4:
		win_col = Color(1.0, 0.62, 0.18, 0.60)

	while bx < LEVEL_W + 200:
		var bw := 110.0 + (b_idx % 5) * 20.0
		var bh := 190.0 + (b_idx % 7) * 26.0
		var bc = palette[b_idx % palette.size()]

		var bld := ColorRect.new()
		bld.position = Vector2(bx, 620 - bh)
		bld.size     = Vector2(bw, bh)
		bld.color    = bc
		bld.z_index  = -52
		add_child(bld)
		level_nodes.append(bld)

		# Janelas (2 colunas x 3 linhas)
		for wr in range(3):
			for wc in range(2):
				var wx := bx + 14 + wc * (bw * 0.55)
				var wy := 620 - bh + 18 + wr * 52
				var win := ColorRect.new()
				win.position = Vector2(wx, wy)
				win.size     = Vector2(15, 18)
				win.color    = win_col
				win.z_index  = -51
				add_child(win)
				level_nodes.append(win)

		bx    += bw + 10 + (b_idx % 3) * 18
		b_idx += 1

	# Arvores (fases ao ar livre)
	if idx <= 1:
		for tx in [200.0, 580.0, 980.0, 1440.0, 1820.0, 2260.0, 2700.0]:
			_create_tree(tx, 620)

	# Props: placa "Café Loop" na fase 1
	if idx == 0:
		var awning := ColorRect.new()
		awning.position = Vector2(-240, 420)
		awning.size     = Vector2(180, 16)
		awning.color    = Color(0.82, 0.14, 0.10)
		awning.z_index  = -42
		add_child(awning)
		level_nodes.append(awning)

		var sign_bg := ColorRect.new()
		sign_bg.position = Vector2(-240, 436)
		sign_bg.size     = Vector2(180, 52)
		sign_bg.color    = Color(0.94, 0.88, 0.78)
		sign_bg.z_index  = -42
		add_child(sign_bg)
		level_nodes.append(sign_bg)

		var sign_lbl := Label.new()
		sign_lbl.text     = "Café Loop"
		sign_lbl.position = Vector2(-238, 448)
		sign_lbl.size     = Vector2(176, 30)
		sign_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sign_lbl.add_theme_font_size_override("font_size", 18)
		sign_lbl.add_theme_color_override("font_color", Color(0.18, 0.10, 0.05))
		sign_lbl.z_index = -41
		add_child(sign_lbl)
		level_nodes.append(sign_lbl)

		# Hidrante e lixeiras
		_create_hydrant(340.0, 608.0)
		_create_trash(760.0, 606.0)
		_create_trash(1900.0, 606.0)

	# Postes de luz nas ruas
	if idx <= 1:
		for px in [500.0, 1100.0, 1700.0, 2300.0, 2900.0]:
			_create_lamppost(px, 620)

func _create_tree(x: float, gy: float) -> void:
	var trunk := ColorRect.new()
	trunk.position = Vector2(x - 6, gy - 46)
	trunk.size     = Vector2(12, 46)
	trunk.color    = Color(0.42, 0.26, 0.10)
	trunk.z_index  = -48
	add_child(trunk)
	level_nodes.append(trunk)
	for layer in range(3):
		var cw  := 50.0 - layer * 7
		var cap := ColorRect.new()
		cap.position = Vector2(x - cw / 2, gy - 46 - 28 - layer * 20)
		cap.size     = Vector2(cw, 34)
		cap.color    = Color(0.20 + layer * 0.05, 0.60 - layer * 0.04, 0.20)
		cap.z_index  = -47
		add_child(cap)
		level_nodes.append(cap)

func _create_hydrant(x: float, y: float) -> void:
	var body := ColorRect.new()
	body.position = Vector2(x, y)
	body.size     = Vector2(14, 22)
	body.color    = Color(0.88, 0.14, 0.10)
	body.z_index  = -42
	add_child(body)
	level_nodes.append(body)
	var top := ColorRect.new()
	top.position = Vector2(x - 2, y - 6)
	top.size     = Vector2(18, 7)
	top.color    = Color(0.78, 0.10, 0.08)
	top.z_index  = -41
	add_child(top)
	level_nodes.append(top)

func _create_trash(x: float, y: float) -> void:
	var body := ColorRect.new()
	body.position = Vector2(x, y)
	body.size     = Vector2(20, 28)
	body.color    = Color(0.30, 0.34, 0.30)
	body.z_index  = -42
	add_child(body)
	level_nodes.append(body)
	var lid := ColorRect.new()
	lid.position = Vector2(x - 2, y - 6)
	lid.size     = Vector2(24, 7)
	lid.color    = Color(0.38, 0.40, 0.36)
	lid.z_index  = -41
	add_child(lid)
	level_nodes.append(lid)

func _create_lamppost(x: float, gy: float) -> void:
	var pole := ColorRect.new()
	pole.position = Vector2(x - 2, gy - 120)
	pole.size     = Vector2(4, 120)
	pole.color    = Color(0.55, 0.52, 0.50)
	pole.z_index  = -44
	add_child(pole)
	level_nodes.append(pole)
	var lamp := ColorRect.new()
	lamp.position = Vector2(x - 10, gy - 128)
	lamp.size     = Vector2(20, 10)
	lamp.color    = Color(0.95, 0.90, 0.55, 0.90)
	lamp.z_index  = -43
	add_child(lamp)
	level_nodes.append(lamp)

# ============================================================
# BACKGROUND
# ============================================================

func _create_background() -> void:
	bg_rect          = ColorRect.new()
	bg_rect.size     = Vector2(6000, 2000)
	bg_rect.position = Vector2(-1000, -500)
	bg_rect.color    = Color(0.15, 0.18, 0.28)
	bg_rect.z_index  = -100
	add_child(bg_rect)
