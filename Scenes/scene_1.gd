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
	_update_moving_platforms(delta)  # <- adicione esta linha
	hud.update_ability(rob.get_ability_ratio(), bog.get_ability_ratio())

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

	loopy_start = Vector2(level["loopy_start"][0], level["loopy_start"][1])
	loopy_end   = Vector2(level["loopy_end"][0],   level["loopy_end"][1])
	_create_loopy(loopy_start)

	camera.global_position = current_character.global_position
	hud.update_level_info(level, idx, GameManager.get_level_count())
	hud.update_character(current_character == rob)
	hud.update_lives(GameManager.lives)
	hud.show_intro(level, idx)
	hud.start_fade(-1, Callable())

func _clear_level() -> void:
	_moving_platforms.clear()  # <- adicione esta linha
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
	# Linha 1 - imediata
	_add_victory_label("Você alcançou o Loopy!", 130, 50, Color(0.28, 1.0, 0.42))
	await get_tree().create_timer(1.6).timeout

	_add_victory_label("Loopy para no meio da rua...", 220, 22, Color(0.78, 0.78, 0.90))
	await get_tree().create_timer(1.5).timeout

	_add_victory_label("Ele olha ao redor, confuso.", 258, 22, Color(0.78, 0.78, 0.90))
	await get_tree().create_timer(1.5).timeout

	_add_victory_label("Seus olhos focam lentamente...", 296, 22, Color(0.78, 0.78, 0.90))
	await get_tree().create_timer(1.8).timeout

	_add_victory_label("— Rob?  Bog?  O que aconteceu?  Onde eu estava? —", 358, 22, Color(1.0, 0.92, 0.38))
	await get_tree().create_timer(1.8).timeout

	_add_victory_label("O efeito do chá foi embora.", 402, 18, Color(0.70, 0.70, 0.82))
	await get_tree().create_timer(1.4).timeout

	_add_victory_label("Os três amigos estão juntos novamente!", 452, 30, Color(0.95, 0.95, 1.0))
	await get_tree().create_timer(1.2).timeout

	_add_victory_label("Pressione  ESPAÇO  para voltar ao menu", 526, 17, Color(0.48, 0.48, 0.60))

	await get_tree().create_timer(0.5).timeout
	_wait_for_menu_input()

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
