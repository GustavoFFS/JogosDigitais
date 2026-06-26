extends Node2D

## Cena principal - Lost & Loopy
## Gerencia plataformas, personagens, camera, Loopy, checkpoints, hazards e transicoes.
var shake_strength: float = 0.0
var shake_decay: float = 3.0

@onready var rob:    CharacterBase = $Rob
@onready var bog:    CharacterBase = $Bog
@onready var camera: Camera2D      = $Camera2D

var hud: GameHUD
var current_character: CharacterBase
var level_nodes: Array[Node] = []
var is_exiting: bool = false

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
var bg_rect: TextureRect
var bg_texture: TextureRect      # NOVO: Onde a imagem vai ficar

# Tela de vitoria
var victory_overlay: Control = null

# Plataformas moveis
var _moving_platforms: Array = []

const DEATH_Y: float = 950.0

# Estrelas
var _stars_left_in_level: int = 0
var _collected_keys: Array = []

# Blocos empurráveis (para mostrar dica de proximidade)
var _pushable_blocks: Array = []
var _gates: Array = []
var _switches: Array = []

# Pause overlay
var _pause_overlay: Control = null

# Death overlay
var _death_overlay: Control = null
var _snow_particles: CPUParticles2D = null
var _dust_particles: CPUParticles2D = null
var _insect_particles: CPUParticles2D = null

# Sistema de diálogos
var _dialogue_system: DialogueSystem = null
var _dialogue_shown_for_level: int = -1

# Sistema de Iluminação
var _canvas_mod: CanvasModulate = null
var _character_lights: Array = []

# ============================================================
# INICIALIZACAO
# ============================================================

func _ready() -> void:
	_remove_old_static_bodies()
	_create_background()
	hud = GameHUD.new()
	add_child(hud)
	hud.pause_requested.connect(_toggle_pause)
	_setup_dialogue_system()
	_setup_characters()
	_load_level()

func apply_shake(strength: float) -> void:
	shake_strength = strength

func _remove_old_static_bodies() -> void:
	for child in get_children():
		if child is StaticBody2D or child.get_class() == "TileMap" or child is TileMapLayer:
			child.queue_free()

# ============================================================
# GAME LOOP (INPUT -> UPDATE -> RENDER)
# ============================================================

func _process(delta: float) -> void:
	_game_loop_input()
	_game_loop_update(delta)
	_game_loop_render()

	if shake_strength > 0:
		shake_strength = move_toward(shake_strength, 0.0, shake_decay * delta)
		camera.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		camera.offset = Vector2.ZERO

## 1. ETAPA DE INPUT
func _game_loop_input() -> void:
	# Verificação de Inputs contínuos ou baseados em polling por frame (se houver no futuro)
	pass

func _unhandled_input(event: InputEvent) -> void:
	# Captura de Inputs discretos por eventos do SO
	# Bloqueia input durante diálogos (o sistema de diálogo consome o ESPAÇO)
	if _dialogue_system and _dialogue_system.is_active():
		return
	if event.is_action_pressed("switch_character") and not get_tree().paused and not hud.showing_intro and not hud.fading and not is_exiting and not hud.transitioning and not rob.is_dead and not bog.is_dead:
		_switch_character()
	if event.is_action_pressed("pause") and not hud.showing_intro and victory_overlay == null and not is_exiting and not hud.transitioning:
		# Bloqueia pause se tela de morte estiver ativa
		if _death_overlay and is_instance_valid(_death_overlay):
			return
		if hud.is_help_visible():
			hud._close_help()
		else:
			_toggle_pause()

## 2. ETAPA DE UPDATE (Física, Movimentação e Regras de Jogo)
func _game_loop_update(delta: float) -> void:
	# Controla ativação do cronômetro de speedrun
	var dialogue_active := _dialogue_system != null and _dialogue_system.is_active()
	GameManager.is_timer_active = not hud.showing_intro and not hud.fading and victory_overlay == null and not dialogue_active and not hud.transitioning
	
	# Inicia diálogos quando a intro terminar
	_check_dialogue_trigger()
	
	_update_camera(delta)
	_update_loopy(delta)
	_check_death()
	_check_pushable_blocks_bounds()
	_update_pushable_hints_logic()

## Plataformas móveis precisam rodar no mesmo passo da física para que
## o personagem em cima receba o platform_velocity sincronizado com seu
## próprio _physics_process (caso contrário trava/treme na vertical).
func _physics_process(delta: float) -> void:
	_update_moving_platforms(delta)

## 3. ETAPA DE RENDER (Atualização de HUD, Modulates e Elementos Visuais)
func _game_loop_render() -> void:
	hud.update_ability(rob.get_ability_ratio(), bog.get_ability_ratio())
	_render_pushable_hints_visuals()

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
	_pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	hud.add_child(_pause_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.72)
	_pause_overlay.add_child(dim)

	var center_box = Control.new()
	center_box.name = "CenterBox"
	center_box.set_anchors_preset(Control.PRESET_CENTER)
	center_box.offset_left = -576
	center_box.offset_top = -324
	center_box.offset_right = 576
	center_box.offset_bottom = 324
	_pause_overlay.add_child(center_box)

	var box := ColorRect.new()
	box.size     = Vector2(440, 430)
	box.position = Vector2(356, 144)
	box.color    = Color(0.10, 0.12, 0.20, 0.98)
	center_box.add_child(box)

	var border := ColorRect.new()
	border.size     = Vector2(440, 4)
	border.position = Vector2(356, 144)
	border.color    = Color(0.30, 0.75, 1.0, 0.9)
	_pause_overlay.get_node("CenterBox").add_child(border)

	var title := Label.new()
	title.text     = "— PAUSA —"
	title.position = Vector2(356, 166)
	title.size     = Vector2(440, 44)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	_pause_overlay.get_node("CenterBox").add_child(title)

	var info := Label.new()
	info.text     = "★  Estrelas: %d / %d" % [GameManager.stars_collected, GameManager.stars_total_game]
	info.position = Vector2(356, 214)
	info.size     = Vector2(440, 24)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 16)
	info.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
	_pause_overlay.get_node("CenterBox").add_child(info)

	var btn_resume := Button.new()
	btn_resume.text = "Continuar"
	btn_resume.position = Vector2(416, 256)
	btn_resume.size     = Vector2(320, 44)
	btn_resume.add_theme_font_size_override("font_size", 20)
	btn_resume.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_resume.pressed.connect(_close_pause)
	
	var resume_key = InputEventKey.new()
	resume_key.keycode = KEY_ESCAPE
	var resume_shortcut = Shortcut.new()
	resume_shortcut.events = [resume_key]
	btn_resume.shortcut = resume_shortcut
	
	_pause_overlay.get_node("CenterBox").add_child(btn_resume)

	var btn_help := Button.new()
	btn_help.text = "Dicas"
	btn_help.position = Vector2(416, 310)
	btn_help.size     = Vector2(320, 44)
	btn_help.add_theme_font_size_override("font_size", 19)
	btn_help.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_help.pressed.connect(hud._show_help)
	_pause_overlay.get_node("CenterBox").add_child(btn_help)

	var btn_options := Button.new()
	btn_options.text = "Opções"
	btn_options.position = Vector2(416, 364)
	btn_options.size     = Vector2(320, 44)
	btn_options.add_theme_font_size_override("font_size", 20)
	btn_options.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_options.pressed.connect(_show_options_menu)
	_pause_overlay.get_node("CenterBox").add_child(btn_options)

	var btn_menu := Button.new()
	btn_menu.text = "Voltar ao Menu"
	btn_menu.position = Vector2(416, 418)
	btn_menu.size     = Vector2(320, 44)
	btn_menu.add_theme_font_size_override("font_size", 20)
	btn_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_menu.pressed.connect(_show_quit_confirm)
	_pause_overlay.get_node("CenterBox").add_child(btn_menu)

	var hint := Label.new()
	hint.text     = "ESC  para continuar"
	hint.position = Vector2(356, 484)
	hint.size     = Vector2(440, 24)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.62))
	_pause_overlay.get_node("CenterBox").add_child(hint)

# ============================================================
# OPÇÕES DE TELA (no pause)
# ============================================================

var _options_overlay: Control = null

func _show_options_menu() -> void:
	if _options_overlay and is_instance_valid(_options_overlay):
		return

	_options_overlay = Control.new()
	_options_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_options_overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	hud.add_child(_options_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.82)
	_options_overlay.add_child(dim)

	var center_box = Control.new()
	center_box.name = "CenterBox"
	center_box.set_anchors_preset(Control.PRESET_CENTER)
	center_box.offset_left = -576
	center_box.offset_top = -324
	center_box.offset_right = 576
	center_box.offset_bottom = 324
	_options_overlay.add_child(center_box)

	var box := ColorRect.new()
	box.position = Vector2(326, 50)
	box.size     = Vector2(500, 540)
	box.color    = Color(0.08, 0.10, 0.16, 0.98)
	center_box.add_child(box)

	var top := ColorRect.new()
	top.position = Vector2(326, 50)
	top.size     = Vector2(500, 4)
	top.color    = Color(0.40, 0.75, 1.00, 0.9)
	center_box.add_child(top)

	var title := Label.new()
	title.text = "TAMANHO DA TELA"
	title.position = Vector2(326, 70)
	title.size = Vector2(500, 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30))
	_options_overlay.get_node("CenterBox").add_child(title)

	var y_pos = 110
	var resolutions = [
		{"name": "1152 x 648 (Janela Padrão)", "w": 1152, "h": 648},
		{"name": "1280 x 720 (Janela HD)", "w": 1280, "h": 720},
		{"name": "1920 x 1080 (Janela Full HD)", "w": 1920, "h": 1080}
	]

	for res in resolutions:
		var btn = Button.new()
		btn.text = res["name"]
		btn.position = Vector2(376, y_pos)
		btn.size = Vector2(400, 40)
		btn.add_theme_font_size_override("font_size", 18)
		btn.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		btn.pressed.connect(func():
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(res["w"], res["h"]))
			var screen_size = DisplayServer.screen_get_size()
			var window_size = DisplayServer.window_get_size()
			DisplayServer.window_set_position((screen_size - window_size) / 2)
			GameManager.save_game()
		)
		_options_overlay.get_node("CenterBox").add_child(btn)
		y_pos += 50

	var btn_full = Button.new()
	btn_full.text = "Tela Cheia"
	btn_full.position = Vector2(376, y_pos)
	btn_full.size = Vector2(400, 40)
	btn_full.add_theme_font_size_override("font_size", 18)
	btn_full.add_theme_color_override("font_color", Color(0.50, 0.88, 0.55))
	btn_full.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_full.pressed.connect(func():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		GameManager.save_game()
	)
	_options_overlay.get_node("CenterBox").add_child(btn_full)
	
	var title_audio := Label.new()
	title_audio.text = "ÁUDIO"
	title_audio.position = Vector2(326, 320)
	title_audio.size = Vector2(500, 30)
	title_audio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_audio.add_theme_font_size_override("font_size", 24)
	title_audio.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30))
	_options_overlay.get_node("CenterBox").add_child(title_audio)

	var audio_configs = [
		{"name": "Volume Geral", "val": GameManager.master_volume, "bus": "Master", "var": "master_volume"},
		{"name": "Música", "val": GameManager.bgm_volume, "bus": "BGM", "var": "bgm_volume"},
		{"name": "Efeitos", "val": GameManager.sfx_volume, "bus": "SFX", "var": "sfx_volume"}
	]
	
	var a_y = 370
	for cfg in audio_configs:
		var lbl = Label.new()
		lbl.text = cfg["name"]
		lbl.position = Vector2(376, a_y)
		lbl.size = Vector2(150, 30)
		lbl.add_theme_font_size_override("font_size", 16)
		_options_overlay.get_node("CenterBox").add_child(lbl)
		
		var slider = HSlider.new()
		slider.position = Vector2(536, a_y + 4)
		slider.size = Vector2(240, 20)
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = cfg["val"]
		slider.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		slider.value_changed.connect(func(v: float):
			GameManager.set(cfg["var"], v)
			SoundManager.set_bus_volume(cfg["bus"], v)
			GameManager.save_game()
		)
		_options_overlay.get_node("CenterBox").add_child(slider)
		a_y += 40

	var btn_close := Button.new()
	btn_close.text     = "Voltar"
	btn_close.position = Vector2(376, 520)
	btn_close.size     = Vector2(400, 42)
	btn_close.add_theme_font_size_override("font_size", 18)
	btn_close.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_close.pressed.connect(_close_options_menu)
	_options_overlay.get_node("CenterBox").add_child(btn_close)

func _close_options_menu() -> void:
	if _options_overlay and is_instance_valid(_options_overlay):
		_options_overlay.queue_free()
	_options_overlay = null

func _close_pause() -> void:
	if _pause_overlay and is_instance_valid(_pause_overlay):
		_pause_overlay.queue_free()
	_pause_overlay = null
	get_tree().paused = false

var _quit_confirm_overlay: Control = null

func _show_quit_confirm() -> void:
	if _quit_confirm_overlay and is_instance_valid(_quit_confirm_overlay):
		return

	_quit_confirm_overlay = Control.new()
	_quit_confirm_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_quit_confirm_overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	hud.add_child(_quit_confirm_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.85)
	_quit_confirm_overlay.add_child(dim)

	var center_box = Control.new()
	center_box.set_anchors_preset(Control.PRESET_CENTER)
	center_box.offset_left = -576
	center_box.offset_top = -324
	center_box.offset_right = 576
	center_box.offset_bottom = 324
	_quit_confirm_overlay.add_child(center_box)

	var box := ColorRect.new()
	box.position = Vector2(376, 224)
	box.size     = Vector2(400, 200)
	box.color    = Color(0.12, 0.10, 0.16, 0.98)
	center_box.add_child(box)

	var border := ColorRect.new()
	border.position = Vector2(376, 224)
	border.size     = Vector2(400, 4)
	border.color    = Color(0.95, 0.35, 0.35, 0.9)
	center_box.add_child(border)

	var title := Label.new()
	title.text = "VOLTAR AO MENU?"
	title.position = Vector2(376, 250)
	title.size = Vector2(400, 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30))
	center_box.add_child(title)

	var msg := Label.new()
	msg.text = "O progresso não salvo será perdido."
	msg.position = Vector2(376, 290)
	msg.size = Vector2(400, 30)
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 14)
	msg.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	center_box.add_child(msg)

	var btn_yes := Button.new()
	btn_yes.text = "Sim"
	btn_yes.position = Vector2(406, 340)
	btn_yes.size = Vector2(150, 42)
	btn_yes.add_theme_font_size_override("font_size", 18)
	btn_yes.add_theme_color_override("font_color", Color(0.95, 0.45, 0.45))
	btn_yes.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_yes.pressed.connect(_do_quit_to_menu)
	center_box.add_child(btn_yes)

	var btn_no := Button.new()
	btn_no.text = "Não"
	btn_no.position = Vector2(596, 340)
	btn_no.size = Vector2(150, 42)
	btn_no.add_theme_font_size_override("font_size", 18)
	btn_no.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_no.pressed.connect(func():
		if _quit_confirm_overlay and is_instance_valid(_quit_confirm_overlay):
			_quit_confirm_overlay.queue_free()
		_quit_confirm_overlay = null
	)
	center_box.add_child(btn_no)

func _do_quit_to_menu() -> void:
	if _quit_confirm_overlay and is_instance_valid(_quit_confirm_overlay):
		_quit_confirm_overlay.queue_free()
	_quit_confirm_overlay = null
	
	if _pause_overlay and is_instance_valid(_pause_overlay):
		_pause_overlay.queue_free()
	_pause_overlay = null
	
	if _death_overlay and is_instance_valid(_death_overlay):
		_death_overlay.queue_free()
	_death_overlay = null
	
	get_tree().paused = false
	SoundManager.stop_ambient()
	GameManager.return_to_menu()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# ============================================================
# CARREGAMENTO DE FASE
# ============================================================

func _setup_characters() -> void:
	current_character = rob
	rob.set_active(true)
	bog.set_active(false)
	rob.add_collision_exception_with(bog)
	bog.add_collision_exception_with(rob)

func _create_gravity_zone(x: float, y: float, w: float, h: float) -> void:
	var area := GravityZone.new()
	area.position = Vector2(x + w / 2.0, y + h / 2.0)
	area.width = w
	area.height = h

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size   = Vector2(w, h)
	shape.shape = rect
	area.add_child(shape)

	area.collision_layer = 0
	area.collision_mask  = 1

	add_child(area)
	level_nodes.append(area)

func _load_level() -> void:
	Engine.time_scale = 1.0
	camera.zoom = Vector2(1.0, 1.0)
	_clear_level()

	var level := GameManager.get_current_level()
	var idx   := GameManager.current_level_index

	rob.scale = Vector2.ONE
	bog.scale = Vector2.ONE
	rob.collision_mask = 1
	bog.collision_mask = 1
	rob.process_mode = Node.PROCESS_MODE_INHERIT
	bog.process_mode = Node.PROCESS_MODE_INHERIT

	rob.apply_modifiers(level["modifiers"])
	bog.apply_modifiers(level["modifiers"])
	rob.revive()
	bog.revive()

	var spawn_r := Vector2(level["spawn_rob"][0], level["spawn_rob"][1])
	var spawn_b := Vector2(level["spawn_bog"][0], level["spawn_bog"][1])

	if has_checkpoint:
		print("[DEBUG] Loading checkpoint: Rob=", checkpoint_rob, ", Bog=", checkpoint_bog)
		rob.global_position = checkpoint_rob
		bog.global_position = checkpoint_bog
	else:
		print("[DEBUG] Loading start spawn: Rob=", spawn_r, ", Bog=", spawn_b)
		rob.global_position = spawn_r
		bog.global_position = spawn_b

	rob.force_update_transform()
	bog.force_update_transform()

	rob.velocity = Vector2.ZERO
	bog.velocity = Vector2.ZERO

	var bg_color: Color = level.get("bg_color", Color(0.13, 0.16, 0.24))
	
	# Cria um gradiente de céu vertical baseado na cor do nível
	var sky_grad := GradientTexture2D.new()
	sky_grad.width = 256
	sky_grad.height = 256
	sky_grad.fill = GradientTexture2D.FILL_LINEAR
	sky_grad.fill_from = Vector2(0.5, 0.0) # topo
	sky_grad.fill_to = Vector2(0.5, 1.0) # base
	
	var g := Gradient.new()
	g.set_color(0, bg_color.lightened(0.15))
	g.set_color(1, bg_color.darkened(0.35))
	sky_grad.gradient = g
	
	bg_rect.texture = sky_grad
	bg_rect.visible = true # Sempre visível para mostrar o degradê do céu
	
	if level.has("bg_image") and level["bg_image"] != "":
		var tex = load(level["bg_image"])
		bg_texture.texture = tex
		bg_texture.visible = true
		
		# Ajusta tamanho e escala do background para evitar repetição vertical
		var tex_h = float(tex.get_height())
		var target_h = 928.0
		var scale_factor = target_h / tex_h
		bg_texture.scale = Vector2(scale_factor, scale_factor)
		bg_texture.size = Vector2(24000.0 / scale_factor, tex_h)
		bg_texture.position = Vector2(-2000, -100)
		
		# Modula a silhueta da cidade com um tom do céu mais escuro e atmosférico
		bg_texture.modulate = Color(bg_color.r * 1.3, bg_color.g * 1.3, bg_color.b * 1.45, 0.35)
	else:
		bg_texture.visible = false
	
	var plat_color: Color = level.get("platform_color", Color.WHITE)
	var mods: Dictionary = level.get("modifiers", {})
	if mods.get("friction", 1.0) < 1.0:
		plat_color = Color(0.55, 0.85, 0.95, 0.9)
	
	for p in level.get("platforms", []):
		_create_platform(p[0], p[1], p[2], p[3], plat_color)
	
	for mp in level.get("moving_platforms", []):
		_spawn_moving_platform(mp, plat_color)
				
	for cp in level.get("checkpoints", []):
		_create_checkpoint(cp[0], cp[1])
	for h in level.get("hazards", []):
		_create_hazard(h[0], h[1], h[2], h[3])
	for gz in level.get("gravity_zones", []):
		_create_gravity_zone(gz[0], gz[1], gz[2], gz[3])

	_create_level_exit(Vector2(level["exit_pos"][0], level["exit_pos"][1]))

	for pb in level.get("pushable_blocks", []):
		_create_pushable_block(pb[0], pb[1], pb[2], pb[3])
		
	for bb in level.get("breakable_blocks", []):
		_create_breakable_block(bb[0], bb[1], bb[2], bb[3])
		
	for k in level.get("keys", []):
		_create_key(k[0], k[1], k[2])
		
	for lk in level.get("locks", []):
		_create_lock(lk[0], lk[1], lk[2], lk[3], lk[4])
		
	# Jump Pads (Molas) e Speed Pads (Aceleradores)
	for jp in level.get("jump_pads", []):
		_create_jump_pad(jp[0], jp[1], jp[2], jp[3])
	for sp in level.get("speed_pads", []):
		_create_speed_pad(sp[0], sp[1], sp[2], sp[3], sp[4])

	# Puzzles: Switches (Botões), Gates (Portões), Crumbling Platforms (Instáveis) e Levers (Alavancas)
	for sw in level.get("switches", []):
		var is_heavy := false
		if sw.size() > 5:
			is_heavy = sw[5]
		_create_switch(sw[0], sw[1], sw[2], sw[3], sw[4], is_heavy)
	for gt in level.get("gates", []):
		_create_gate(gt[0], gt[1], gt[2], gt[3], gt[4])
	for cp in level.get("crumbling_platforms", []):
		_create_crumbling_platform(cp[0], cp[1], cp[2], cp[3])
	for lv in level.get("levers", []):
		_create_lever(lv[0], lv[1], lv[2], lv[3], lv[4])
	for se in level.get("secret_exits", []):
		_create_secret_exit(se[0], se[1], se[2], se[3], se[4])
	for ls in level.get("light_switches", []):
		_create_light_switch(ls[0], ls[1], ls[2], ls[3])

	if level.get("dark_mode", false):
		_setup_dark_mode()

	# Snow effect
	if _snow_particles and is_instance_valid(_snow_particles):
		_snow_particles.queue_free()
		_snow_particles = null
	if level.get("snow_effect", false):
		_create_snow_effect()

	# Dust effect
	if _dust_particles and is_instance_valid(_dust_particles):
		_dust_particles.queue_free()
		_dust_particles = null
	if level.get("dust_effect", false):
		_create_dust_effect()

	# Insect effect
	if _insect_particles and is_instance_valid(_insect_particles):
		_insect_particles.queue_free()
		_insect_particles = null
	if level.get("insect_effect", false):
		_create_insect_effect()

	var stars: Array = level.get("stars", [])
	GameManager.stars_in_level = stars.size()
	_stars_left_in_level = stars.size()
	for i in range(stars.size()):
		if GameManager.is_star_collected(idx, i):
			_stars_left_in_level -= 1
			continue
		_create_star(stars[i][0], stars[i][1], idx, i)
	hud.update_stars(GameManager.stars_collected, GameManager.stars_total_game)

	var spiders: Array = level.get("spiders", [])
	for s in spiders:
		_create_spider(s[0], s[1], s[2], s[3])

	loopy_start = Vector2(level["loopy_start"][0], level["loopy_start"][1])
	loopy_end   = Vector2(level["loopy_end"][0],   level["loopy_end"][1])
	_create_loopy(loopy_start)

	camera.global_position = current_character.global_position
	hud.update_level_info(level, idx, GameManager.get_level_count())
	hud.update_character(current_character == rob)
	hud.update_deaths(GameManager.deaths)
	hud.show_intro(level, idx)
	hud.start_fade(-1, Callable())
	
	# Inicia som ambiente da fase
	var ambient: String = level.get("ambient_type", "")
	if ambient != "":
		SoundManager.play_ambient(ambient)
		
	# Ajusta som da música se for local fechado
	SoundManager.set_muffled_audio(level.get("is_indoor", false))

func _clear_level() -> void:
	if _snow_particles and is_instance_valid(_snow_particles):
		_snow_particles.queue_free()
		_snow_particles = null

	if _dust_particles and is_instance_valid(_dust_particles):
		_dust_particles.queue_free()
		_dust_particles = null

	if _insect_particles and is_instance_valid(_insect_particles):
		_insect_particles.queue_free()
		_insect_particles = null

	_moving_platforms.clear()
	_pushable_blocks.clear()
	_gates.clear()
	_switches.clear()
	_collected_keys.clear()
	for light in _character_lights:
		if is_instance_valid(light):
			light.queue_free()
	_character_lights.clear()
	_canvas_mod = null
	hud.update_keys(0)
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
	body.add_to_group("ice_platforms")

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size   = Vector2(w, h)
	shape.shape = rect
	body.add_child(shape)

	_draw_platform_surface(body, w, h, color)

	add_child(body)
	level_nodes.append(body)

## Desenha a textura visual da plataforma: corpo base + faixa de topo
## clara (relevo) + faixa inferior escura (sombra) + tijolos pintados.
func _draw_platform_surface(body: Node, w: float, h: float, color: Color) -> void:
	var base := ColorRect.new()
	base.size     = Vector2(w, h)
	base.position = Vector2(-w / 2.0, -h / 2.0)
	base.color    = color
	body.add_child(base)

	# Faixa de relevo (topo) — quase branca
	var top_line := ColorRect.new()
	top_line.size     = Vector2(w, 4)
	top_line.position = Vector2(-w / 2.0, -h / 2.0)
	top_line.color    = color.lightened(0.45)
	body.add_child(top_line)

	# Faixa de sombra (rodapé)
	var bot_line := ColorRect.new()
	bot_line.size     = Vector2(w, 3)
	bot_line.position = Vector2(-w / 2.0, h / 2.0 - 3)
	bot_line.color    = color.darkened(0.45)
	body.add_child(bot_line)

	# Tijolos verticais (linhas escuras a cada 32 px, alternando offset)
	var brick_w := 32.0
	var row_h: float = max((h - 4) / 2.0, 6.0)
	var n_cols := int(ceil(w / brick_w))
	for row in range(2):
		var offset: float = 0.0 if row % 2 == 0 else brick_w / 2.0
		for col in range(n_cols + 1):
			var bx: float = -w / 2.0 + col * brick_w + offset
			if bx <= -w / 2.0 or bx >= w / 2.0:
				continue
			var line := ColorRect.new()
			line.size     = Vector2(1.5, row_h - 1)
			line.position = Vector2(bx, -h / 2.0 + 4 + row * row_h)
			line.color    = color.darkened(0.35)
			body.add_child(line)

func _spawn_moving_platform(mp: Dictionary, color: Color) -> void:
	var w: float = mp.get("w", 110.0)
	var h: float = mp.get("h", 18.0)

	# AnimatableBody2D + sync_to_physics carrega o personagem corretamente
	# (StaticBody2D movido por global_position causa judder visual e quebra
	# a detecção de is_on_floor a cada frame em plataformas verticais).
	var body := AnimatableBody2D.new()
	body.sync_to_physics = true
	body.global_position = mp["start_pos"]
	body.add_to_group("ice_platforms")

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size   = Vector2(w, h)
	shape.shape = rect
	body.add_child(shape)

	_draw_platform_surface(body, w, h, color)

	add_child(body)
	level_nodes.append(body)

	_moving_platforms.append({
		"node":      body,
		"start_pos": mp["start_pos"],
		"end_pos":   mp["end_pos"],
		"speed":     mp["speed"],
		"w":         w,
		"h":         h,
		"to_end":    true
	})

func _update_moving_platforms(delta: float) -> void:
	for mp in _moving_platforms:
		var platform_node = mp.get("node")
		if not is_instance_valid(platform_node):
			continue

		var prev_pos: Vector2 = platform_node.global_position
		var is_to_end: bool = mp.get("to_end", true)
		var target_pos: Vector2 = mp.get("end_pos") if is_to_end else mp.get("start_pos")

		platform_node.global_position = prev_pos.move_toward(target_pos, mp.get("speed", 100.0) * delta)

		if platform_node.global_position.distance_to(target_pos) < 0.1:
			mp["to_end"] = not is_to_end

		var platform_velocity: Vector2 = (platform_node.global_position - prev_pos) / delta

		for character in [rob, bog]:
			if is_instance_valid(character):
				if not character.has_meta("platform_velocity"):
					character.set_meta("platform_velocity", Vector2.ZERO)
				
				if character.is_on_floor():
					var char_pos: Vector2 = character.global_position
					var plat_pos: Vector2 = platform_node.global_position
					var half_w: float = mp.get("w", 110.0) / 2.0
					
					if abs(char_pos.x - plat_pos.x) < half_w and char_pos.y <= plat_pos.y + 8.0:
						character.set_meta("platform_velocity", platform_velocity)

# ============================================================
# SPIDERS (ARANHAS)
# ============================================================

func _create_spider(x: float, y: float, range_y: float, speed: float) -> void:
	var area = Area2D.new()
	area.position = Vector2(x, y)
	
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	area.add_child(shape)
	
	# Fio de teia (cresce para cima)
	var thread = ColorRect.new()
	thread.size = Vector2(2, 2000)
	thread.position = Vector2(-1, -2000)
	thread.color = Color(0.8, 0.8, 0.8, 0.5)
	area.add_child(thread)
	
	# Corpo da aranha
	var visual = Node2D.new()
	area.add_child(visual)
	
	var body = ColorRect.new()
	body.size = Vector2(24, 24)
	body.position = Vector2(-12, -12)
	body.color = Color(0.05, 0.05, 0.08)
	visual.add_child(body)
	
	var eye1 = ColorRect.new()
	eye1.size = Vector2(4, 4)
	eye1.position = Vector2(-6, 2)
	eye1.color = Color(0.9, 0.1, 0.1)
	visual.add_child(eye1)
	
	var eye2 = ColorRect.new()
	eye2.size = Vector2(4, 4)
	eye2.position = Vector2(2, 2)
	eye2.color = Color(0.9, 0.1, 0.1)
	visual.add_child(eye2)
	
	# Pernas
	for leg_y in [-6, 0, 6]:
		var legL = ColorRect.new()
		legL.size = Vector2(8, 2)
		legL.position = Vector2(-20, leg_y)
		legL.color = Color(0.05, 0.05, 0.08)
		visual.add_child(legL)
		
		var legR = ColorRect.new()
		legR.size = Vector2(8, 2)
		legR.position = Vector2(12, leg_y)
		legR.color = Color(0.05, 0.05, 0.08)
		visual.add_child(legR)
	
	area.collision_layer = 0
	area.collision_mask = 1
	
	var script = GDScript.new()
	script.source_code = "extends Area2D\n\nvar main_scene: Node2D\n\nfunc _ready():\n\tmain_scene = get_parent()\n\tbody_entered.connect(_on_touch)\n\nfunc _on_touch(body):\n\tif (body == main_scene.rob or body == main_scene.bog):\n\t\tmain_scene._on_player_died()\n"
	script.reload()
	area.set_script(script)
	
	var duration = range_y / speed
	var tw = area.create_tween().set_loops()
	tw.tween_property(area, "position:y", y + range_y, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(area, "position:y", y, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	add_child(area)
	level_nodes.append(area)

# ============================================================
# CHECKPOINTS
# ============================================================

func _create_checkpoint(x: float, y: float) -> void:
	var area := Area2D.new()
	area.position = Vector2(x, y)
	
	var is_active: bool = has_checkpoint and abs(x - (checkpoint_rob.x + 28.0)) < 1.0
	area.set_meta("activated", is_active)

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size   = Vector2(28, 64)
	shape.shape = rect
	area.add_child(shape)
	
	area.z_index = -1

	var pole := ColorRect.new()
	pole.size     = Vector2(4, 94)
	pole.position = Vector2(-2, -62)
	pole.color    = Color(0.75, 0.75, 0.78)
	area.add_child(pole)

	var flag := Polygon2D.new()
	flag.polygon = PackedVector2Array([
		Vector2(2, -60),
		Vector2(24, -53),
		Vector2(2, -46)
	])
	flag.color    = Color(0.20, 0.90, 0.35) if is_active else Color(0.92, 0.82, 0.12)
	flag.name     = "Flag"
	area.add_child(flag)

	area.collision_layer = 0
	area.collision_mask  = 1
	area.body_entered.connect(_on_checkpoint_entered.bind(area))

	add_child(area)
	level_nodes.append(area)

func _on_checkpoint_entered(body: Node, area: Area2D) -> void:
	if body != rob and body != bog:
		return
	if hud.fading or hud.showing_intro or is_exiting or hud.transitioning:
		return
	if area.get_meta("activated", false):
		return
	area.set_meta("activated", true)
	SoundManager.play_sfx("collect")

	# Ambos os personagens ressurgem ao lado da bandeira (não onde estavam ao tocar)
	# Limita o Y para garantir que nunca renasçam abaixo do abismo caso o gatilho ative atrasado durante quedas
	var safe_y: float = area.global_position.y - 35.0
	checkpoint_rob = Vector2(area.global_position.x - 28, safe_y)
	checkpoint_bog = Vector2(area.global_position.x + 28, safe_y)
	has_checkpoint = true
	print("[DEBUG] Checkpoint entered! flag_y=", area.global_position.y, ", safe_y=", safe_y, ", checkpoint_rob=", checkpoint_rob, ", checkpoint_bog=", checkpoint_bog)

	var flag := area.get_node_or_null("Flag")
	if flag:
		flag.color = Color(0.20, 0.90, 0.35)

	hud.show_checkpoint_notification()

# ============================================================
# HAZARDS (ZONAS DE MORTE)
# ============================================================

func _create_hazard(x: float, y: float, w: float, h: float) -> void:
	var static_body := StaticBody2D.new()
	static_body.position = Vector2(x + w / 2.0, y + h / 2.0)
	static_body.collision_layer = 1 
	static_body.collision_mask = 1

	var solid_shape := CollisionShape2D.new()
	var solid_rect  := RectangleShape2D.new()
	solid_rect.size  = Vector2(w, h)
	solid_shape.shape = solid_rect
	static_body.add_child(solid_shape)

	var death_area := Area2D.new()
	var detector_shape := CollisionShape2D.new()
	var detector_rect  := RectangleShape2D.new()
	detector_rect.size  = Vector2(w + 2.0, h + 2.0) 
	detector_shape.shape = detector_rect
	death_area.add_child(detector_shape)
	
	death_area.collision_layer = 0
	death_area.collision_mask  = 1
	death_area.body_entered.connect(_on_hazard_entered)
	static_body.add_child(death_area)

	var spike_poly: Polygon2D = Polygon2D.new()
	var pts: PackedVector2Array = PackedVector2Array()
	var spike_width: float = 16.0
	var spike_height: float = 6.0
	var n_spikes: int = int(max(1.0, w / spike_width))
	var actual_w: float = w / float(n_spikes)
	var start_x: float = -w / 2.0
	var top_y: float = -h / 2.0
	
	pts.append(Vector2(start_x, top_y))
	for i in range(n_spikes):
		pts.append(Vector2(start_x + i * actual_w + actual_w/2.0, top_y - spike_height))
		pts.append(Vector2(start_x + (i + 1) * actual_w, top_y))
	pts.append(Vector2(start_x + w, top_y + h))
	pts.append(Vector2(start_x, top_y + h))
	
	spike_poly.polygon = pts
	spike_poly.color = Color(0.75, 0.15, 0.15, 0.95)
	static_body.add_child(spike_poly)

	add_child(static_body)
	level_nodes.append(static_body)

func _on_hazard_entered(body: Node) -> void:
	if (body == rob or body == bog) and not body.is_dead and not hud.fading and not hud.showing_intro and not is_exiting and not hud.transitioning:
		_on_player_died()

# ============================================================
# SAIDA DA FASE
# ============================================================

func _create_level_exit(pos: Vector2) -> void:
	var level_exit_script = load("res://Scripts/level_exit.gd")
	var area = level_exit_script.new()
	area.position = pos
	area.name     = "LevelExit"

	area.body_entered.connect(_on_exit_body_entered.bind(area))

	add_child(area)
	level_nodes.append(area)

func _on_exit_body_entered(body: Node, exit_area: Area2D) -> void:
	if body == current_character and not hud.fading and not is_exiting and not hud.transitioning:
		is_exiting = true
		if rob:
			rob.velocity = Vector2.ZERO
			rob.collision_mask = 0
			rob.process_mode = Node.PROCESS_MODE_DISABLED
		if bog:
			bog.velocity = Vector2.ZERO
			bog.collision_mask = 0
			bog.process_mode = Node.PROCESS_MODE_DISABLED
			
		var char_tw = create_tween().set_parallel(true).bind_node(self)
		char_tw.set_ignore_time_scale(true)
		char_tw.tween_property(body, "global_position", exit_area.global_position, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		char_tw.tween_property(body, "scale", Vector2.ZERO, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

		SoundManager.play_sfx("collect")
		
		# Efeito de câmera lenta e zoom usando Tween (ignora escala de tempo)
		var tween := create_tween().bind_node(self)
		tween.set_ignore_time_scale(true)
		
		# Suavemente diminui time_scale de 1.0 para 0.2 em 0.25s
		tween.tween_property(Engine, "time_scale", 0.2, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		# Suavemente aumenta zoom de 1.0 para 1.25 em 0.3s
		tween.tween_property(camera, "zoom", Vector2(1.25, 1.25), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		# Mantém a câmera lenta por 0.8s (tempo real)
		tween.tween_interval(0.8)
		
		# Retorna time_scale para 1.0 e avança de fase
		tween.tween_callback(func():
			is_exiting = false
			Engine.time_scale = 1.0
			_complete_level()
		)

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

	var pmat := PhysicsMaterial.new()
	pmat.friction = 0.0
	pmat.bounce   = 0.0
	body.physics_material_override = pmat

	var shape := CollisionShape2D.new()
	var rect  := RectangleShape2D.new()
	rect.size   = Vector2(w, h)
	shape.shape = rect
	body.add_child(shape)

	var visual := ColorRect.new()
	visual.size     = Vector2(w, h)
	visual.position = Vector2(-w / 2.0, -h / 2.0)
	visual.color    = Color(0.58, 0.38, 0.22)
	body.add_child(visual)

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

	var stripe := ColorRect.new()
	stripe.size     = Vector2(w, 2)
	stripe.position = Vector2(-w / 2.0, 0)
	stripe.color    = Color(0.42, 0.26, 0.14)
	body.add_child(stripe)

	var tag := Label.new()
	tag.text     = "BOG"
	tag.position = Vector2(-w / 2.0, -h / 2.0 - 20)
	tag.size     = Vector2(w, 18)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.add_theme_font_size_override("font_size", 12)
	tag.add_theme_color_override("font_color", Color(1.0, 0.62, 0.26))
	body.add_child(tag)

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
	body.set_meta("start_position", body.position)

func _check_pushable_blocks_bounds() -> void:
	for block in _pushable_blocks:
		if is_instance_valid(block) and block is RigidBody2D:
			if block.global_position.y > DEATH_Y:
				var start_pos: Vector2 = block.get_meta("start_position", block.global_position)
				block.global_position = start_pos
				block.linear_velocity = Vector2.ZERO
				block.angular_velocity = 0.0

## Atualiza a lógica/texto da dica de proximidade (Etapa de Update)
func _update_pushable_hints_logic() -> void:
	if not current_character or victory_overlay != null:
		return
		
	for block in _pushable_blocks:
		if not is_instance_valid(block):
			continue
		var hint: Label = block.get_node_or_null("Hint")
		if hint == null:
			continue
			
		var dist: float = block.global_position.distance_to(current_character.global_position)
		block.set_meta("player_distance", dist) # Guarda a distância calculada para a etapa de Render
		
		if dist <= 160.0:
			if current_character == bog:
				hint.text = "↔  Caminhe contra a caixa para empurrar"
				hint.add_theme_color_override("font_color", Color(0.55, 1.0, 0.55))
			else:
				hint.text = "Troque para o BOG  [TAB]  para empurrar"
				hint.add_theme_color_override("font_color", Color(1.0, 0.78, 0.30))

## Renderiza as mudanças de opacidade baseadas na distância (Etapa de Render)
func _render_pushable_hints_visuals() -> void:
	if victory_overlay != null:
		return
		
	for block in _pushable_blocks:
		if not is_instance_valid(block):
			continue
		var hint: Label = block.get_node_or_null("Hint")
		if hint == null:
			continue
			
		var dist: float = block.get_meta("player_distance", 9999.0)
		if dist > 160.0:
			hint.modulate.a = lerp(hint.modulate.a, 0.0, 0.15)
		else:
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

	var star_visual: Polygon2D = Polygon2D.new()
	var pts: PackedVector2Array = PackedVector2Array()
	var outer_radius: float = 14.0
	var inner_radius: float = 6.0
	for i in range(10):
		var angle: float = float(i) * PI / 5.0 - PI / 2.0
		var r: float = outer_radius if i % 2 == 0 else inner_radius
		pts.append(Vector2(cos(angle), sin(angle)) * r)
	star_visual.polygon = pts
	star_visual.color = Color(1.0, 0.88, 0.30)
	
	# Efeito de raios brilhantes ao redor
	var rays := Node2D.new()
	rays.name = "Rays"
	for i in range(8):
		var ray := Line2D.new()
		ray.width = 2.0
		ray.default_color = Color(1.0, 0.9, 0.5, 0.6)
		var angle: float = float(i) * PI / 4.0
		var dir := Vector2(cos(angle), sin(angle))
		ray.points = PackedVector2Array([dir * 18.0, dir * 28.0])
		rays.add_child(ray)
	star_visual.add_child(rays)
	
	area.add_child(star_visual)

	var tw := area.create_tween().set_loops()
	tw.tween_property(star_visual, "position:y", -6.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(star_visual, "position:y",  0.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var ray_rot_tw := rays.create_tween().set_loops()
	ray_rot_tw.tween_property(rays, "rotation", PI * 2.0, 5.0).from(0.0)
	
	var ray_scale_tw := rays.create_tween().set_loops()
	ray_scale_tw.tween_property(rays, "scale", Vector2(1.2, 1.2), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ray_scale_tw.tween_property(rays, "scale", Vector2(0.8, 0.8), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

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
	SoundManager.play_sfx("collect")
	apply_shake(2.0)
	_spawn_star_burst_particles(area.global_position)

	var tw := area.create_tween().set_parallel(true)
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
	rect.size       = Vector2(24, 50)
	shape.shape     = rect
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
		loopy_body.velocity.x = dir.x * LOOPY_SPEED * 3.1
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
	SoundManager.play_sfx("switch")
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
	if hud.fading or hud.showing_intro or is_exiting or hud.transitioning:
		return

	if not current_character.is_dead and current_character.global_position.y > DEATH_Y:
		print("[DEBUG] current_character died! pos=", current_character.global_position)
		_on_player_died()
		return

	var other := bog if current_character == rob else rob
	
	if not other.is_dead and other.global_position.y > DEATH_Y:
		_on_player_died()
		return

func _on_player_died() -> void:
	# Evita contar a morte várias vezes enquanto a tela de morte está
	# subindo (o personagem continua abaixo do DEATH_Y por alguns frames
	# antes do pause efetivar).
	if _death_overlay and is_instance_valid(_death_overlay):
		return
	if rob:
		rob.die()
	if bog:
		bog.die()
	SoundManager.play_sfx("death")
	GameManager.register_death()
	hud.update_deaths(GameManager.deaths)
	_show_death_screen()

func _reload_current_level() -> void:
	_load_level()

# ============================================================
# TELA DE MORTE (pausa o jogo até o jogador escolher)
# ============================================================

func _show_death_screen() -> void:
	if _death_overlay and is_instance_valid(_death_overlay):
		return
	get_tree().paused = true

	_death_overlay = Control.new()
	_death_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_death_overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	hud.add_child(_death_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.18, 0.02, 0.05, 0.86)
	_death_overlay.add_child(dim)

	var center_box = Control.new()
	center_box.name = "CenterBox"
	center_box.set_anchors_preset(Control.PRESET_CENTER)
	center_box.offset_left = -576
	center_box.offset_top = -324
	center_box.offset_right = 576
	center_box.offset_bottom = 324
	_death_overlay.add_child(center_box)

	var box := ColorRect.new()
	box.position = Vector2(266, 134)
	box.size     = Vector2(620, 380)
	box.color    = Color(0.08, 0.05, 0.07, 0.97)
	center_box.add_child(box)

	var border_top := ColorRect.new()
	border_top.position = Vector2(266, 134)
	border_top.size     = Vector2(620, 6)
	border_top.color    = Color(0.95, 0.25, 0.35)
	_death_overlay.get_node("CenterBox").add_child(border_top)

	var border_bot := ColorRect.new()
	border_bot.position = Vector2(266, 508)
	border_bot.size     = Vector2(620, 6)
	border_bot.color    = Color(0.50, 0.15, 0.20)
	_death_overlay.get_node("CenterBox").add_child(border_bot)

	var title := Label.new()
	title.text     = "💀  VOCÊ MORREU  💀"
	title.position = Vector2(266, 172)
	title.size     = Vector2(620, 70)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 46)
	title.add_theme_color_override("font_color", Color(1.0, 0.32, 0.42))
	_death_overlay.get_node("CenterBox").add_child(title)

	var sub_msg := Label.new()
	sub_msg.text = "Sem limite de vidas — tente quantas vezes precisar."
	sub_msg.position = Vector2(266, 252)
	sub_msg.size     = Vector2(620, 24)
	sub_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_msg.add_theme_font_size_override("font_size", 14)
	sub_msg.add_theme_color_override("font_color", Color(0.65, 0.65, 0.72))
	_death_overlay.get_node("CenterBox").add_child(sub_msg)

	var stats := Label.new()
	stats.text = "★  %d / %d        💀  %d morte%s" % [
		GameManager.stars_collected, GameManager.stars_total_game,
		GameManager.deaths, "" if GameManager.deaths == 1 else "s"
	]
	stats.position = Vector2(266, 286)
	stats.size     = Vector2(620, 30)
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 18)
	stats.add_theme_color_override("font_color", Color(0.95, 0.85, 0.40))
	_death_overlay.get_node("CenterBox").add_child(stats)

	# --- BOTÃO DE TENTAR NOVAMENTE ---
	var btn_retry := Button.new()
	btn_retry.position = Vector2(326, 338)
	btn_retry.size     = Vector2(500, 58) # Altura levemente maior para os 2 textos
	btn_retry.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_retry.pressed.connect(_retry_from_death)
	_death_overlay.get_node("CenterBox").add_child(btn_retry)
	
	# Texto Principal do Botão Retry
	var lbl_retry_main := Label.new()
	lbl_retry_main.text = "Tentar Novamente"
	lbl_retry_main.position = Vector2(0, 6)
	lbl_retry_main.size = Vector2(500, 26)
	lbl_retry_main.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_retry_main.add_theme_font_size_override("font_size", 20)
	btn_retry.add_child(lbl_retry_main)

	# Subtítulo do Botão Retry
	var lbl_retry_sub := Label.new()
	lbl_retry_sub.text = "[ ESPAÇO ]"
	lbl_retry_sub.position = Vector2(0, 32)
	lbl_retry_sub.size = Vector2(500, 20)
	lbl_retry_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_retry_sub.add_theme_font_size_override("font_size", 14)
	lbl_retry_sub.add_theme_color_override("font_color", Color(0.65, 0.65, 0.72))
	btn_retry.add_child(lbl_retry_sub)

	# Atalho Retry
	var retry_key = InputEventKey.new()
	retry_key.keycode = KEY_SPACE
	var retry_shortcut = Shortcut.new()
	retry_shortcut.events = [retry_key]
	btn_retry.shortcut = retry_shortcut


	# --- BOTÃO DE VOLTAR AO MENU ---
	var btn_menu := Button.new()
	btn_menu.position = Vector2(326, 408)
	btn_menu.size     = Vector2(500, 58)
	btn_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_menu.pressed.connect(_show_quit_confirm)
	_death_overlay.add_child(btn_menu)
	
	# Texto Principal do Botão Menu
	var lbl_menu_main := Label.new()
	lbl_menu_main.text = "Voltar ao Menu"
	lbl_menu_main.position = Vector2(0, 6)
	lbl_menu_main.size = Vector2(500, 26)
	lbl_menu_main.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_menu_main.add_theme_font_size_override("font_size", 20)
	btn_menu.add_child(lbl_menu_main)

	# Subtítulo do Botão Menu
	var lbl_menu_sub := Label.new()
	lbl_menu_sub.text = "[ ESC ]"
	lbl_menu_sub.position = Vector2(0, 32)
	lbl_menu_sub.size = Vector2(500, 20)
	lbl_menu_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_menu_sub.add_theme_font_size_override("font_size", 14)
	lbl_menu_sub.add_theme_color_override("font_color", Color(0.65, 0.65, 0.72))
	btn_menu.add_child(lbl_menu_sub)

	# Atalho Menu
	var menu_key = InputEventKey.new()
	menu_key.keycode = KEY_ESCAPE
	var menu_shortcut = Shortcut.new()
	menu_shortcut.events = [menu_key]
	btn_menu.shortcut = menu_shortcut

	# (Sem tween de fade-in para evitar problemas com o tree pausado.)
func _retry_from_death() -> void:
	if _death_overlay and is_instance_valid(_death_overlay):
		_death_overlay.queue_free()
	_death_overlay = null
	get_tree().paused = false
	hud.start_fade(1, _reload_current_level)



func _go_to_menu() -> void:
	SoundManager.stop_ambient()
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# ============================================================
# SISTEMA DE DIÁLOGOS
# ============================================================

func _setup_dialogue_system() -> void:
	_dialogue_system = DialogueSystem.new()
	add_child(_dialogue_system)
	_dialogue_system.dialogue_finished.connect(_on_dialogue_finished)

func _check_dialogue_trigger() -> void:
	# Dispara diálogos quando a intro da fase terminar
	if hud.showing_intro or hud.fading or is_exiting or hud.transitioning:
		return
	if _dialogue_system and _dialogue_system.is_active():
		return
	if GameManager.current_level_index >= GameManager.levels.size():
		return
	if _dialogue_shown_for_level == GameManager.current_level_index:
		return
	
	var level := GameManager.get_current_level()
	var dialogues: Array = level.get("dialogues", [])
	if dialogues.is_empty():
		_dialogue_shown_for_level = GameManager.current_level_index
		return
	
	_dialogue_shown_for_level = GameManager.current_level_index
	_dialogue_system.start_dialogue(dialogues, rob, bog, camera)

func _on_dialogue_finished() -> void:
	# Diálogo concluído — jogo prossegue normalmente
	pass

# ============================================================
# COMPLETAR FASE
# ============================================================

func _complete_level() -> void:
	var current_level_data := GameManager.get_current_level()
	var from_name: String = current_level_data.get("name", "")
	
	if GameManager.next_level():
		var next_level_data := GameManager.get_current_level()
		var to_name: String = next_level_data.get("name", "")
		# Usa transição cinematográfica com barras
		SoundManager.stop_ambient()
		hud.start_level_transition(from_name, to_name, _load_next_level)
	else:
		SoundManager.stop_ambient()
		_show_victory()

func _load_next_level() -> void:
	has_checkpoint = false
	_dialogue_shown_for_level = -1  # Permite diálogo na nova fase
	_setup_characters()
	_load_level()

# ============================================================
# VITORIA - LOOPY VOLTA A CONSCIENCIA
# ============================================================

func _show_victory() -> void:
	if victory_overlay:
		return

	if rob:
		rob.process_mode = Node.PROCESS_MODE_DISABLED
	if bog:
		bog.process_mode = Node.PROCESS_MODE_DISABLED

	SoundManager.play_sfx("victory")
	victory_overlay       = Control.new()
	victory_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.add_child(victory_overlay)

	var dim = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.04, 0.08, 0.94)
	victory_overlay.add_child(dim)

	var center_box = Control.new()
	center_box.name = "CenterBox"
	center_box.set_anchors_preset(Control.PRESET_CENTER)
	center_box.offset_left = -576
	center_box.offset_top = -324
	center_box.offset_right = 576
	center_box.offset_bottom = 324
	victory_overlay.add_child(center_box)

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
	victory_overlay.get_node("CenterBox").add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "modulate:a", 1.0, 0.55)

func _run_victory_sequence() -> void:
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

	var t := GameManager.elapsed_time
	var minutes := int(t / 60.0)
	var seconds := int(fmod(t, 60.0))
	var msec := int(fmod(t, 1.0) * 1000.0)
	var time_str := "%02d:%02d.%03d" % [minutes, seconds, msec]

	var stats_msg := "★  %d / %d   ·   💀  %d morte%s   ·   ⏱  %s" % [
		got, total, GameManager.deaths,
		"" if GameManager.deaths == 1 else "s",
		time_str
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

func _tier_color(tier: int) -> Color:
	match tier:
		3: return Color(1.0, 0.85, 0.25)   
		2: return Color(1.0, 0.92, 0.55)   
		1: return Color(0.85, 0.92, 1.0)   
		_: return Color(0.85, 0.85, 0.95)

# ============================================================
# CENA VISUAL DO REENCONTRO (os 3 amigos juntos)
# ============================================================

func _add_victory_sky(tier: int = 0) -> void:
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
	victory_overlay.get_node("CenterBox").add_child(sky)
	var dusk := ColorRect.new()
	dusk.position = Vector2(0, 310)
	dusk.size     = Vector2(1152, 80)
	dusk.color    = dusk_col
	victory_overlay.get_node("CenterBox").add_child(dusk)
	var glow := ColorRect.new()
	glow.position = Vector2(0, 390)
	glow.size     = Vector2(1152, 80)
	glow.color    = glow_col
	victory_overlay.get_node("CenterBox").add_child(glow)

	if tier == 3:
		for i in range(40):
			var sx: float = 30.0 + (i * 67) % 1100
			var sy: float = 240.0 + (i * 31) % 70
			var twk := ColorRect.new()
			twk.position = Vector2(sx, sy)
			twk.size     = Vector2(3, 3)
			twk.color    = Color(1.0, 0.95, 0.70)
			victory_overlay.get_node("CenterBox").add_child(twk)
			var tw := create_tween().set_loops()
			tw.tween_property(twk, "modulate:a", 0.3, 0.6 + (i % 5) * 0.15)
			tw.tween_property(twk, "modulate:a", 1.0, 0.6 + (i % 5) * 0.15)

func _add_reunion_scene(tier: int = 0) -> void:
	var scene := Control.new()
	scene.position = Vector2(0, 0)
	scene.size     = Vector2(1152, 648)
	scene.modulate.a = 0.0
	victory_overlay.get_node("CenterBox").add_child(scene)

	if tier >= 2:
		var halo := ColorRect.new()
		halo.position = Vector2(388, 380)
		halo.size     = Vector2(376, 220)
		halo.color    = Color(1.0, 0.88, 0.30, 0.18 if tier == 2 else 0.30)
		scene.add_child(halo)

	for i in range(9):
		var bx: float = 40.0 + i * 130.0
		var bh: float = 60.0 + ((i * 37) % 50)
		_v_rect(scene, bx, 430.0 - bh, 110.0, bh, Color(0.18, 0.14, 0.26))
		for jy in range(3):
			for jx in range(3):
				if (i + jx + jy) % 3 == 0:
					_v_rect(scene, bx + 12.0 + jx * 30, 430.0 - bh + 10.0 + jy * 16,
							10.0, 8.0, Color(1.0, 0.85, 0.45, 0.9))

	_v_rect(scene, 540.0, 345.0, 72.0, 72.0, Color(1.0, 0.78, 0.35))
	_v_rect(scene, 510.0, 395.0, 132.0, 26.0, Color(1.0, 0.58, 0.28, 0.55))

	_v_rect(scene, 0.0, 470.0, 1152.0, 115.0, Color(0.22, 0.16, 0.14))
	_v_rect(scene, 0.0, 470.0, 1152.0, 4.0,   Color(0.12, 0.09, 0.06))
	_v_rect(scene, 0.0, 540.0, 1152.0, 2.0, Color(0.35, 0.28, 0.20))

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

	_add_character_sprite(scene, "res://Assets/Characters/Main_2/Idle.png", 7, 50, 420.0, 570.0, 1.6, false)
	_draw_loopy_full(scene, 576.0, 570.0, 1.3)
	_add_character_sprite(scene, "res://Assets/Characters/Main_1/Idle.png", 6, 50, 730.0, 570.0, 1.6, true)

	_add_heart(scene, 400.0, 340.0)
	_add_heart(scene, 750.0, 345.0)
	_v_label(scene, "♪", 485.0, 335.0, 30, Color(1.0, 0.85, 0.45))
	_v_label(scene, "♫", 650.0, 340.0, 30, Color(1.0, 0.75, 0.35))

	var tw := create_tween()
	tw.tween_property(scene, "modulate:a", 1.0, 0.85)

func _add_character_sprite(parent: Node, path: String, h_frames: int, crop_top: float, feet_x: float, feet_y: float, scl: float, flip: bool = false) -> void:
	var sprite := Sprite2D.new()
	var tex: Texture2D = load(path)
	if tex == null:
		return
	sprite.texture  = tex
	
	var tex_w := tex.get_width()
	var tex_h := tex.get_height()
	
	if crop_top > 0:
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, crop_top, tex_w, tex_h - crop_top)
		tex_h -= int(crop_top)

	sprite.hframes  = h_frames
	sprite.frame    = 0
	sprite.scale    = Vector2(scl, scl)
	sprite.flip_h   = flip
	
	var frame_h := float(tex_h)
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
	_pr(parent, cx, cy, s, -14,   9, 12, 9, shoe)
	_pr(parent, cx, cy, s,   2,   9, 12, 9, shoe)
	_pr(parent, cx, cy, s, -14,   2, 12, 2, dark)
	_pr(parent, cx, cy, s,   2,   2, 12, 2, dark)
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
	_pr(parent, cx, cy, s,   3, 93, 3, 3, dark)
	_pr(parent, cx, cy, s, -2, 88, 4, 4, Color(skin.r * 0.85, skin.g * 0.72, skin.b * 0.60))
	_pr(parent, cx, cy, s, -4, 82, 8, 1.5, dark)
	_pr(parent, cx, cy, s, -15, 118, 30, 14, beanie)
	_pr(parent, cx, cy, s, -14, 106, 28, 3, Color(beanie.r * 0.65, beanie.g * 0.65, beanie.b * 0.60))
	_pr(parent, cx, cy, s,   2, 125, 7, 6, leaf)
	_pr(parent, cx, cy, s,   6, 130, 4, 4, leaf)
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
	_pr(parent, cx, cy, s, -12,  8,  10, 8, shoe)
	_pr(parent, cx, cy, s,   2,  8,  10, 8, shoe)
	_pr(parent, cx, cy, s, -10, 32, 9, 24, pants)
	_pr(parent, cx, cy, s,   1, 32, 9, 24, pants)
	_pr(parent, cx, cy, s, -14, 60, 28, 28, shirt)
	_pr(parent, cx, cy, s, -18, 55, 4, 22, skin)
	_pr(parent, cx, cy, s,  14, 55, 4, 22, skin)
	_pr(parent, cx, cy, s,  -9, 80, 18, 20, skin)
	_pr(parent, cx, cy, s, -10, 84, 20, 7, hair)
	_pr(parent, cx, cy, s, -5, 74, 2, 2, dark)
	_pr(parent, cx, cy, s,   3, 74, 2, 2, dark)
	_pr(parent, cx, cy, s, -3, 68, 6, 1.5, Color(0.6, 0.2, 0.2))
	_v_label(parent, "Rob", cx - 24.0, cy + 14.0, 14, Color(0.55, 0.88, 1.0))

func _draw_bog_sil(parent: Node, cx: float, cy: float, s: float) -> void:
	var skin  := Color(0.98, 0.78, 0.62)
	var shirt := Color(1.00, 0.55, 0.20)
	var pants := Color(0.36, 0.24, 0.14)
	var shoe  := Color(0.18, 0.14, 0.10)
	var hair  := Color(0.10, 0.08, 0.06)
	var dark  := Color(0.05, 0.05, 0.05)
	_pr(parent, cx, cy, s, -14,  8,  12, 8, shoe)
	_pr(parent, cx, cy, s,   2,  8,  12, 8, shoe)
	_pr(parent, cx, cy, s, -12, 34, 11, 26, pants)
	_pr(parent, cx, cy, s,   1, 34, 11, 26, pants)
	_pr(parent, cx, cy, s, -18, 64, 36, 30, shirt)
	_pr(parent, cx, cy, s, -22, 58, 4, 22, skin)
	_pr(parent, cx, cy, s,  18, 58, 4, 22, skin)
	_pr(parent, cx, cy, s, -11, 86, 22, 22, skin)
	_pr(parent, cx, cy, s, -12, 90, 24, 7, hair)
	_pr(parent, cx, cy, s, -6, 80, 2, 2, dark)
	_pr(parent, cx, cy, s,   4, 80, 2, 2, dark)
	_pr(parent, cx, cy, s, -3, 72, 6, 1.5, Color(0.5, 0.2, 0.2))
	_v_label(parent, "Bog", cx - 24.0, cy + 14.0, 14, Color(1.0, 0.65, 0.30))

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
	# Cor de fundo sólida (predomina, para o cenário ficar legível)
	bg_rect          = TextureRect.new()
	bg_rect.size     = Vector2(12000, 2400)
	bg_rect.position = Vector2(-2000, -600)
	bg_rect.z_index  = -100
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(bg_rect)

	# Imagem da cidade — fica esmaecida e tileada horizontalmente
	# para que as plataformas e personagens fiquem nítidos.
	bg_texture = TextureRect.new()
	bg_texture.z_index  = -90
	bg_texture.position = Vector2(-2000, -100)
	bg_texture.size     = Vector2(12000, 900)
	bg_texture.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	bg_texture.stretch_mode   = TextureRect.STRETCH_TILE
	bg_texture.modulate       = Color(1, 1, 1, 0.32)  # mais clean / menos poluído
	add_child(bg_texture)

# ============================================================
# PARTÍCULAS E VISUAIS ADICIONAIS ("JUICE")
# ============================================================

func spawn_jump_particles(pos: Vector2, character_name: String) -> void:
	var color := Color(0.40, 0.75, 1.00) if character_name == "Rob" else Color(1.00, 0.60, 0.25)
	_spawn_dust(pos + Vector2(0, 64), color, 8, -40.0)

func spawn_land_particles(pos: Vector2, character_name: String) -> void:
	var color := Color(0.40, 0.75, 1.00) if character_name == "Rob" else Color(1.00, 0.60, 0.25)
	_spawn_dust(pos + Vector2(0, 64), color, 12, -20.0)
	apply_shake(1.5)

func _spawn_dust(pos: Vector2, color: Color, amount: int, _vel_y: float) -> void:
	var particles := CPUParticles2D.new()
	particles.global_position = pos
	particles.amount = amount
	particles.one_shot = true
	particles.explosiveness = 0.85
	particles.lifetime = 0.35
	particles.spread = 60.0
	particles.direction = Vector2(0, -1)
	particles.gravity = Vector2(0, 80)
	particles.initial_velocity_min = 15.0
	particles.initial_velocity_max = 35.0
	particles.color = color
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.5
	add_child(particles)
	particles.emitting = true
	particles.finished.connect(particles.queue_free)

func _spawn_star_burst_particles(pos: Vector2) -> void:
	var particles := CPUParticles2D.new()
	particles.global_position = pos
	particles.amount = 24
	particles.one_shot = true
	particles.explosiveness = 0.90
	particles.lifetime = 0.55
	particles.spread = 180.0
	particles.gravity = Vector2(0, 25)
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 100.0
	particles.damping_min = 25.0
	particles.damping_max = 45.0
	particles.angular_velocity_min = -180.0
	particles.angular_velocity_max = 180.0

	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		Color(1.0, 0.98, 0.65, 1.0), # Brilho forte central
		Color(1.0, 0.85, 0.30, 0.8), # Amarelo ouro
		Color(1.0, 0.45, 0.10, 0.0)  # Laranja desaparecendo
	])
	grad.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
	particles.color_ramp = grad

	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(0.7, 0.7))
	curve.add_point(Vector2(1.0, 0.0))
	particles.scale_amount_curve = curve

	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 5.0

	add_child(particles)
	particles.emitting = true
	particles.finished.connect(particles.queue_free)

func spawn_dash_ghosts(character: CharacterBase, duration: float) -> void:
	var sprite_node = character.sprite
	if not sprite_node:
		return
	for i in range(4):
		var delay = i * 0.035
		if delay >= duration:
			break
		get_tree().create_timer(delay).timeout.connect(func():
			if is_instance_valid(character) and is_instance_valid(sprite_node):
				_spawn_single_ghost(character, sprite_node)
		)

func _spawn_single_ghost(character: CharacterBase, sprite_node: Sprite2D) -> void:
	var ghost := Sprite2D.new()
	ghost.texture = sprite_node.texture
	ghost.hframes = sprite_node.hframes
	ghost.frame = sprite_node.frame
	ghost.flip_h = sprite_node.flip_h
	ghost.scale = character.scale
	ghost.global_position = character.global_position
	ghost.modulate = Color(0.40, 0.75, 1.00, 0.65)
	add_child(ghost)
	
	var tw := ghost.create_tween().set_parallel(true)
	tw.tween_property(ghost, "modulate:a", 0.0, 0.22)
	tw.tween_property(ghost, "scale", Vector2.ZERO, 0.22)
	tw.chain().tween_callback(ghost.queue_free)

func spawn_impact_wave(pos: Vector2) -> void:
	var debris := CPUParticles2D.new()
	debris.global_position = pos + Vector2(0, 24)
	debris.amount = 16
	debris.one_shot = true
	debris.explosiveness = 0.95
	debris.lifetime = 0.50
	debris.spread = 120.0
	debris.direction = Vector2(0, -1)
	debris.gravity = Vector2(0, 150)
	debris.initial_velocity_min = 50.0
	debris.initial_velocity_max = 120.0
	debris.color = Color(1.00, 0.60, 0.25)
	debris.scale_amount_min = 3.0
	debris.scale_amount_max = 6.0
	add_child(debris)
	debris.emitting = true
	debris.finished.connect(debris.queue_free)
	
	var ring := Node2D.new()
	ring.global_position = pos + Vector2(0, 20)
	
	var ring_script = GDScript.new()
	ring_script.source_code = "extends Node2D\n\nvar radius := 5.0\nvar max_radius := 120.0\nvar color := Color(1.00, 0.70, 0.30, 0.8)\n\nfunc _ready():\n	var tw = create_tween()\n	tw.set_parallel(true)\n	tw.tween_property(self, \"radius\", max_radius, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)\n	tw.tween_property(self, \"color\", Color(1.00, 0.70, 0.30, 0.0), 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)\n	get_tree().create_timer(0.35).timeout.connect(queue_free)\n\nfunc _process(delta):\n	queue_redraw()\n\nfunc _draw():\n	draw_arc(Vector2.ZERO, radius, 0.0, 2.0 * PI, 32, color, 4.0, true)"
	ring_script.reload()
	ring.set_script(ring_script)
	
	add_child(ring)

# ============================================================
# NOVOS OBJETOS INTERATIVOS: JUMP PADS E SPEED BOOST PADS
# ============================================================

func _create_jump_pad(x: float, y: float, w: float, h: float) -> void:
	var area := Area2D.new()
	area.position = Vector2(x + w / 2.0, y + h / 2.0)
	
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	shape.shape = rect
	area.add_child(shape)
	
	var pivot: Node2D = Node2D.new()
	pivot.position = Vector2(0, h / 2.0)
	
	var visual: Node2D = Node2D.new()
	visual.position = Vector2(-w / 2.0, -h)
	
	var base: ColorRect = ColorRect.new()
	base.size = Vector2(w, h * 0.3)
	base.position = Vector2(0, h * 0.7)
	base.color = Color(0.3, 0.3, 0.35)
	visual.add_child(base)
	
	var spring: Line2D = Line2D.new()
	spring.width = 4.0
	spring.default_color = Color(0.7, 0.75, 0.8)
	var pts: PackedVector2Array = PackedVector2Array()
	var start_y: float = h * 0.7
	var end_y: float = 6.0
	var num_coils: int = 3
	var step_y: float = (start_y - end_y) / float(num_coils * 2)
	for i in range(num_coils * 2 + 1):
		var px: float = w * 0.2 if i % 2 == 0 else w * 0.8
		var py: float = start_y - float(i) * step_y
		pts.append(Vector2(px, py))
	spring.points = pts
	visual.add_child(spring)
	
	var pad: ColorRect = ColorRect.new()
	pad.size = Vector2(w, 6)
	pad.position = Vector2(0, 0)
	pad.color = Color(0.95, 0.22, 0.45)
	visual.add_child(pad)
	
	pivot.add_child(visual)
	area.add_child(pivot)
	
	area.collision_layer = 0
	area.collision_mask = 1
	area.body_entered.connect(func(body):
		if body is CharacterBase:
			body.velocity.y = -640.0
			if "is_ground_pounding" in body:
				body.is_ground_pounding = false
			if "is_locked" in body:
				body.is_locked = false
				
			SoundManager.play_sfx("boost")
			apply_shake(4.5)
			
			var tw := area.create_tween()
			pivot.scale = Vector2(1.3, 0.4)
			tw.tween_property(pivot, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_ELASTIC)
	)
	
	add_child(area)
	level_nodes.append(area)

func _create_speed_pad(x: float, y: float, w: float, h: float, dir_x: float) -> void:
	var area := Area2D.new()
	area.position = Vector2(x + w / 2.0, y + h / 2.0)
	
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	shape.shape = rect
	area.add_child(shape)
	
	var visual: ColorRect = ColorRect.new()
	visual.size = Vector2(w, h)
	visual.position = Vector2(-w / 2.0, -h / 2.0)
	visual.color = Color(0.15, 0.65, 0.45, 0.85)
	area.add_child(visual)
	
	var chevron_w: float = 6.0
	var spacing: float = 12.0
	var num_chev: int = 3
	var start_x: float = (-spacing * float(num_chev)) / 2.0 + spacing / 2.0
	
	for i in range(num_chev):
		var chev: Line2D = Line2D.new()
		chev.width = 4.0
		chev.default_color = Color(0.6, 1.0, 0.8)
		var cx: float = start_x + float(i) * spacing
		var sign_dir: float = 1.0 if dir_x > 0 else -1.0
		chev.points = PackedVector2Array([
			Vector2(cx - sign_dir * chevron_w, -h/2.0 + 6.0),
			Vector2(cx + sign_dir * chevron_w, 0.0),
			Vector2(cx - sign_dir * chevron_w, h/2.0 - 6.0)
		])
		area.add_child(chev)
	
	area.collision_layer = 0
	area.collision_mask = 1
	area.body_entered.connect(func(body):
		if body is CharacterBase:
			body.is_locked = true
			body.lock_timer = 0.18
			body.velocity.x = dir_x * body.base_speed * body.speed_mult * 2.5
			body.velocity.y = -100.0
			
			SoundManager.play_sfx("boost")
			apply_shake(3.0)
			_spawn_wind_particles(body.global_position, dir_x)
	)
	
	add_child(area)
	level_nodes.append(area)

func _spawn_wind_particles(pos: Vector2, dir_x: float) -> void:
	var particles := CPUParticles2D.new()
	particles.global_position = pos
	particles.amount = 8
	particles.one_shot = true
	particles.explosiveness = 0.80
	particles.lifetime = 0.30
	particles.spread = 15.0
	particles.direction = Vector2(dir_x, 0)
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 200.0
	particles.initial_velocity_max = 350.0
	particles.color = Color(0.40, 0.90, 0.80, 0.60)
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	add_child(particles)
	particles.emitting = true
	particles.finished.connect(particles.queue_free)

# ============================================================
# PUZZLES: BOTÕES, PORTÕES E PLATAFORMAS QUE CAEM
# ============================================================

func _create_switch(id: int, x: float, y: float, w: float, h: float, is_heavy: bool = false) -> void:
	var area := Area2D.new()
	area.position = Vector2(x + w / 2.0, y + h / 2.0)
	area.name = "Switch_" + str(id)
	area.set_meta("switch_id", id)
	area.set_meta("active_bodies", 0)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w - 4, h)
	shape.shape = rect
	area.add_child(shape)

	var visual: Polygon2D = Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(-w/2.0, h/2.0),
		Vector2(w/2.0, h/2.0),
		Vector2(w/2.0 - 4.0, -h/2.0 + 6.0),
		Vector2(-w/2.0 + 4.0, -h/2.0 + 6.0)
	])
	visual.color = Color(0.25, 0.30, 0.45) if not is_heavy else Color(0.55, 0.20, 0.20)
	visual.name = "Visual"
	area.add_child(visual)

	var top: Polygon2D = Polygon2D.new()
	top.polygon = PackedVector2Array([
		Vector2(-w/2.0 + 4.0, -h/2.0 + 6.0),
		Vector2(w/2.0 - 4.0, -h/2.0 + 6.0),
		Vector2(w/2.0 - 6.0, -h/2.0),
		Vector2(-w/2.0 + 6.0, -h/2.0)
	])
	top.color = Color(0.4, 0.5, 0.7) if not is_heavy else Color(0.8, 0.3, 0.3)
	top.name = "TopLine"
	area.add_child(top)

	var timer_bg: ColorRect = ColorRect.new()
	timer_bg.size = Vector2(w, 4)
	timer_bg.position = Vector2(-w / 2.0, -h / 2.0 - 10)
	timer_bg.color = Color(0.15, 0.15, 0.20, 0.8)
	timer_bg.visible = false
	area.add_child(timer_bg)
	
	var timer_bar: ColorRect = ColorRect.new()
	timer_bar.size = Vector2(w, 4)
	timer_bar.position = Vector2(0, 0)
	timer_bar.color = Color(1.0, 0.85, 0.3)
	timer_bg.add_child(timer_bar)

	var warning_lbl := Label.new()
	warning_lbl.text = "Peso insuficiente.\nAlgo mais pesado é necessário"
	warning_lbl.position = Vector2(-150, -h / 2.0 - 100)
	warning_lbl.size = Vector2(300, 40)
	warning_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_lbl.add_theme_font_size_override("font_size", 14)
	warning_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	warning_lbl.modulate.a = 0.0
	warning_lbl.name = "WarningLbl"
	area.add_child(warning_lbl)

	if is_heavy:
		pass

	area.collision_layer = 0
	area.collision_mask = 1

	area.body_entered.connect(func(body):
		if body is CharacterBase or body is RigidBody2D:
			if is_heavy and body is CharacterBase and body.character_name == "Rob":
				var tw = area.create_tween()
				tw.tween_property(warning_lbl, "modulate:a", 1.0, 0.2)
				return
				
			var count: int = area.get_meta("active_bodies") + 1
			area.set_meta("active_bodies", count)
			if count == 1:
				timer_bg.visible = false
				if area.has_meta("close_tween"):
					var active_tw = area.get_meta("close_tween")
					if is_instance_valid(active_tw):
						active_tw.kill()
					area.remove_meta("close_tween")
				else:
					visual.color = Color(0.25, 0.85, 0.45) if not is_heavy else Color(0.90, 0.60, 0.15)
					top.color = Color(0.55, 1.0, 0.7) if not is_heavy else Color(1.0, 0.80, 0.40)
					top.position.y = 6.0
					SoundManager.play_sfx("switch")
					_set_gates_active(id, true)
	)

	area.body_exited.connect(func(body):
		if body is CharacterBase or body is RigidBody2D:
			if is_heavy and body is CharacterBase and body.character_name == "Rob":
				var tw = area.create_tween()
				tw.tween_property(warning_lbl, "modulate:a", 0.0, 0.2)
				return
				
			var count: int = max(0, area.get_meta("active_bodies") - 1)
			area.set_meta("active_bodies", count)
			if count == 0:
				var close_tw = area.create_tween()
				area.set_meta("close_tween", close_tw)
				timer_bg.visible = true
				timer_bar.size.x = w
				close_tw.tween_property(timer_bar, "size:x", 0.0, 3.0)
				close_tw.tween_callback(func():
					if is_instance_valid(visual) and is_instance_valid(top) and is_instance_valid(area):
						visual.color = Color(0.25, 0.30, 0.45) if not is_heavy else Color(0.55, 0.20, 0.20)
						top.color = Color(0.4, 0.5, 0.7) if not is_heavy else Color(0.8, 0.3, 0.3)
						top.position.y = 0.0
						timer_bg.visible = false
						SoundManager.play_sfx("switch")
						_set_gates_active(id, false)
						area.remove_meta("close_tween")
				)
	)

	add_child(area)
	level_nodes.append(area)
	_switches.append(area)

func _set_gates_active(switch_id: int, active: bool) -> void:
	for gate in _gates:
		if is_instance_valid(gate) and gate.get_meta("switch_id") == switch_id:
			if active:
				gate.open_gate()
			else:
				gate.close_gate()

func _create_gate(switch_id: int, x: float, y: float, w: float, h: float) -> void:
	var gate := StaticBody2D.new()
	gate.position = Vector2(x + w / 2.0, y + h / 2.0)
	gate.name = "Gate_" + str(switch_id)
	gate.set_meta("switch_id", switch_id)
	gate.collision_layer = 1
	gate.collision_mask = 1

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	shape.shape = rect
	gate.add_child(shape)

	var visual: Node2D = Node2D.new()
	visual.name = "Visual"
	gate.add_child(visual)

	var frame_l: ColorRect = ColorRect.new()
	frame_l.size = Vector2(6, h)
	frame_l.position = Vector2(-w/2.0, -h/2.0)
	frame_l.color = Color(0.25, 0.25, 0.3)
	visual.add_child(frame_l)

	var frame_r: ColorRect = ColorRect.new()
	frame_r.size = Vector2(6, h)
	frame_r.position = Vector2(w/2.0 - 6.0, -h/2.0)
	frame_r.color = Color(0.25, 0.25, 0.3)
	visual.add_child(frame_r)

	var frame_t: ColorRect = ColorRect.new()
	frame_t.size = Vector2(w - 12, 10)
	frame_t.position = Vector2(-w/2.0 + 6.0, -h/2.0)
	frame_t.color = Color(0.35, 0.35, 0.4)
	visual.add_child(frame_t)
	
	var num_lasers: int = int(h / 16.0)
	var max_l: float = float(max(1.0, float(num_lasers - 1)))
	for i in range(num_lasers):
		var laser: ColorRect = ColorRect.new()
		laser.size = Vector2(w - 12, 4)
		var l_y: float = -h/2.0 + 16.0 + float(i) * ((h - 20.0) / max_l)
		laser.position = Vector2(-w/2.0 + 6.0, l_y)
		laser.color = Color(0.95, 0.20, 0.25, 0.85)
		visual.add_child(laser)

	var gate_script = GDScript.new()
	gate_script.source_code = "extends StaticBody2D\n\nvar _shape: CollisionShape2D\nvar _visual: Node2D\n\nfunc _ready():\n	_shape = get_child(0)\n	_visual = get_node(\"Visual\")\n\nfunc open_gate():\n	collision_layer = 0\n	collision_mask = 0\n	var tw = create_tween()\n	tw.tween_property(_visual, \"modulate:a\", 0.0, 0.25)\n\nfunc close_gate():\n	collision_layer = 1\n	collision_mask = 1\n	var tw = create_tween()\n	tw.tween_property(_visual, \"modulate:a\", 1.0, 0.25)"
	gate_script.reload()
	gate.set_script(gate_script)

	add_child(gate)
	level_nodes.append(gate)
	_gates.append(gate)

func _create_crumbling_platform(x: float, y: float, w: float, h: float) -> void:
	var plat := StaticBody2D.new()
	plat.position = Vector2(x + w / 2.0, y + h / 2.0)
	plat.collision_layer = 1
	plat.collision_mask = 1
	plat.set_meta("start_pos", plat.position)
	plat.set_meta("is_crumbling", false)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	shape.shape = rect
	plat.add_child(shape)

	var visual := Node2D.new()
	visual.position = Vector2(-w / 2.0, -h / 2.0)
	visual.name = "Visual"
	plat.add_child(visual)

	var bg := ColorRect.new()
	bg.size = Vector2(w, h)
	bg.color = Color(0.65, 0.55, 0.45)
	visual.add_child(bg)

	var border := ReferenceRect.new()
	border.size = Vector2(w, h)
	border.border_color = Color(0.45, 0.35, 0.25)
	border.border_width = 3.0
	border.editor_only = false
	visual.add_child(border)

	var crack1 := Line2D.new()
	crack1.points = PackedVector2Array([
		Vector2(w * 0.3, 0),
		Vector2(w * 0.4, h * 0.5),
		Vector2(w * 0.35, h)
	])
	crack1.width = 3.0
	crack1.default_color = Color(0.3, 0.2, 0.15)
	visual.add_child(crack1)

	var crack2 := Line2D.new()
	crack2.points = PackedVector2Array([
		Vector2(w * 0.7, 0),
		Vector2(w * 0.65, h * 0.6),
		Vector2(w * 0.75, h)
	])
	crack2.width = 3.0
	crack2.default_color = Color(0.3, 0.2, 0.15)
	visual.add_child(crack2)

	var area := Area2D.new()
	area.name = "Area"
	var area_shape := CollisionShape2D.new()
	var area_rect := RectangleShape2D.new()
	area_rect.size = Vector2(w - 6, 8)
	area_shape.shape = area_rect
	area_shape.position = Vector2(0, -h / 2.0 - 4)
	area.add_child(area_shape)
	area.collision_layer = 0
	area.collision_mask = 1
	plat.add_child(area)

	var plat_script = GDScript.new()
	plat_script.source_code = "extends StaticBody2D\n\nvar _start_pos: Vector2\nvar _shape: CollisionShape2D\nvar _visual: Node2D\nvar _area: Area2D\nvar _is_crumbling := false\n\nfunc _ready():\n	_start_pos = get_meta(\"start_pos\")\n	_shape = get_child(0)\n	_visual = get_node(\"Visual\")\n	_area = get_node(\"Area\")\n	_area.body_entered.connect(_on_body_entered)\n\nfunc _on_body_entered(body):\n	if _is_crumbling or not (body is CharacterBase):\n		return\n	_is_crumbling = true\n	var shake_tw = create_tween()\n	for i in range(5):\n		var offset = Vector2(randf_range(-3, 3), randf_range(-1, 1))\n		shake_tw.tween_property(self, \"position\", _start_pos + offset, 0.05)\n	shake_tw.tween_property(self, \"position\", _start_pos, 0.05)\n	await get_tree().create_timer(0.6).timeout\n	collision_layer = 0\n	collision_mask = 0\n	var fall_tw = create_tween().set_parallel(true)\n	fall_tw.tween_property(self, \"position:y\", _start_pos.y + 120.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)\n	fall_tw.tween_property(self, \"modulate:a\", 0.0, 0.4)\n	await get_tree().create_timer(2.5).timeout\n	position = _start_pos\n	modulate.a = 1.0\n	collision_layer = 1\n	collision_mask = 1\n	_is_crumbling = false"
	plat_script.reload()
	plat.set_script(plat_script)

	add_child(plat)
	level_nodes.append(plat)

func _create_breakable_block(x: float, y: float, w: float, h: float) -> void:
	var block := StaticBody2D.new()
	block.add_to_group("breakable")
	block.position = Vector2(x + w / 2.0, y + h / 2.0)
	block.collision_layer = 1
	block.collision_mask = 1
	block.set_meta("start_pos", block.position)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	shape.shape = rect
	block.add_child(shape)

	var visual := Node2D.new()
	visual.position = Vector2(-w / 2.0, -h / 2.0)
	visual.name = "Visual"
	block.add_child(visual)

	var bg := ColorRect.new()
	bg.size = Vector2(w, h)
	bg.color = Color(0.38, 0.38, 0.42)
	visual.add_child(bg)

	var border := ReferenceRect.new()
	border.size = Vector2(w, h)
	border.border_color = Color(0.2, 0.2, 0.25)
	border.border_width = 4.0
	border.editor_only = false
	visual.add_child(border)

	var crack1 := Line2D.new()
	crack1.points = PackedVector2Array([
		Vector2(w * 0.2, 0),
		Vector2(w * 0.4, h * 0.3),
		Vector2(w * 0.3, h * 0.6),
		Vector2(w * 0.5, h)
	])
	crack1.width = 4.0
	crack1.default_color = Color(0.15, 0.15, 0.18)
	visual.add_child(crack1)

	var crack2 := Line2D.new()
	crack2.points = PackedVector2Array([
		Vector2(w * 0.8, 0),
		Vector2(w * 0.6, h * 0.4),
		Vector2(w * 0.7, h * 0.7),
		Vector2(w * 0.9, h)
	])
	crack2.width = 4.0
	crack2.default_color = Color(0.15, 0.15, 0.18)
	visual.add_child(crack2)
	
	var crack3 := Line2D.new()
	crack3.points = PackedVector2Array([
		Vector2(0, h * 0.5),
		Vector2(w * 0.3, h * 0.6)
	])
	crack3.width = 3.0
	crack3.default_color = Color(0.15, 0.15, 0.18)
	visual.add_child(crack3)

	var block_script = GDScript.new()
	block_script.source_code = "extends StaticBody2D\n\nvar _shape: CollisionShape2D\nvar _visual: Node2D\nvar _broken := false\nvar main_scene: Node2D\n\nfunc _ready():\n	_shape = get_child(0)\n	_visual = get_node(\"Visual\")\n	main_scene = get_parent()\n\nfunc break_block():\n	if _broken:\n		return\n	_broken = true\n	collision_layer = 0\n	collision_mask = 0\n	SoundManager.play_sfx(\"impact\")\n	if main_scene and main_scene.has_method(\"apply_shake\"):\n		main_scene.apply_shake(6.0)\n	if main_scene and main_scene.has_method(\"_spawn_dust\"):\n		main_scene._spawn_dust(global_position, Color(0.5, 0.5, 0.55), 18, -30.0)\n	var tw = create_tween().set_parallel(true)\n	tw.tween_property(self, \"scale\", Vector2(1.3, 1.3), 0.15)\n	tw.tween_property(self, \"modulate:a\", 0.0, 0.15)\n	await get_tree().create_timer(0.15).timeout\n	queue_free()"
	block_script.reload()
	block.set_script(block_script)

	add_child(block)
	level_nodes.append(block)

func _create_snow_effect() -> void:
	_snow_particles = CPUParticles2D.new()
	_snow_particles.name = "SnowParticles"
	camera.add_child(_snow_particles)
	_snow_particles.position = Vector2(0, -400)
	_snow_particles.amount = 120
	_snow_particles.lifetime = 8.0
	_snow_particles.preprocess = 6.0
	_snow_particles.local_coords = false
	_snow_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_snow_particles.emission_rect_extents = Vector2(800, 10)
	_snow_particles.direction = Vector2(0.2, 1.0)
	_snow_particles.spread = 15.0
	_snow_particles.gravity = Vector2(0, 15)
	_snow_particles.initial_velocity_min = 40.0
	_snow_particles.initial_velocity_max = 80.0
	_snow_particles.color = Color(0.92, 0.96, 1.0, 0.75)
	_snow_particles.scale_amount_min = 1.5
	_snow_particles.scale_amount_max = 4.0

func _create_dust_effect() -> void:
	_dust_particles = CPUParticles2D.new()
	_dust_particles.name = "DustParticles"
	camera.add_child(_dust_particles)
	_dust_particles.position = Vector2(0, 0)
	_dust_particles.amount = 80
	_dust_particles.lifetime = 8.0
	_dust_particles.preprocess = 6.0
	_dust_particles.local_coords = false
	_dust_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_dust_particles.emission_rect_extents = Vector2(800, 500)
	_dust_particles.direction = Vector2(0.4, -0.1)
	_dust_particles.spread = 30.0
	_dust_particles.gravity = Vector2(0, -2)
	_dust_particles.initial_velocity_min = 8.0
	_dust_particles.initial_velocity_max = 24.0
	
	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		Color(0.80, 0.72, 0.62, 0.0),
		Color(0.80, 0.72, 0.62, 0.35),
		Color(0.80, 0.72, 0.62, 0.35),
		Color(0.80, 0.72, 0.62, 0.0)
	])
	grad.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
	_dust_particles.color_ramp = grad
	
	_dust_particles.scale_amount_min = 1.0
	_dust_particles.scale_amount_max = 3.5

func _create_insect_effect() -> void:
	_insect_particles = CPUParticles2D.new()
	_insect_particles.name = "InsectParticles"
	camera.add_child(_insect_particles)
	_insect_particles.position = Vector2(0, 80)
	_insect_particles.amount = 45
	_insect_particles.lifetime = 4.0
	_insect_particles.preprocess = 4.0
	_insect_particles.local_coords = false
	_insect_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_insect_particles.emission_rect_extents = Vector2(800, 400)
	_insect_particles.direction = Vector2(0, 0)
	_insect_particles.spread = 180.0
	_insect_particles.gravity = Vector2(0, -6)
	_insect_particles.initial_velocity_min = 15.0
	_insect_particles.initial_velocity_max = 45.0
	
	_insect_particles.radial_accel_min = -35.0
	_insect_particles.radial_accel_max = 35.0
	_insect_particles.tangential_accel_min = -45.0
	_insect_particles.tangential_accel_max = 45.0
	
	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		Color(0.18, 0.24, 0.15, 0.0),
		Color(0.20, 0.26, 0.16, 0.70),
		Color(0.18, 0.24, 0.15, 0.70),
		Color(0.18, 0.24, 0.15, 0.0)
	])
	grad.offsets = PackedFloat32Array([0.0, 0.15, 0.85, 1.0])
	_insect_particles.color_ramp = grad
	
	_insect_particles.scale_amount_min = 1.0
	_insect_particles.scale_amount_max = 2.0

# ============================================================
# CHAVES E FECHADURAS
# ============================================================

func _create_key(lock_id: int, x: float, y: float) -> void:
	var area := Area2D.new()
	area.position = Vector2(x, y)
	area.name = "Key_" + str(lock_id)
	area.set_meta("lock_id", lock_id)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 24)
	shape.shape = rect
	area.add_child(shape)

	var visual := Node2D.new()
	visual.position = Vector2(-4, -6)
	
	var head := Polygon2D.new()
	head.polygon = PackedVector2Array([Vector2(-4, -4), Vector2(4, -4), Vector2(4, 4), Vector2(-4, 4)])
	head.color = Color(1.0, 0.85, 0.2)
	visual.add_child(head)
	
	var shaft := Line2D.new()
	shaft.points = PackedVector2Array([Vector2(4, 0), Vector2(16, 0)])
	shaft.width = 4.0
	shaft.default_color = Color(1.0, 0.85, 0.2)
	visual.add_child(shaft)
	
	var teeth1 := Line2D.new()
	teeth1.points = PackedVector2Array([Vector2(10, 0), Vector2(10, 6)])
	teeth1.width = 3.0
	teeth1.default_color = Color(1.0, 0.85, 0.2)
	visual.add_child(teeth1)

	var teeth2 := Line2D.new()
	teeth2.points = PackedVector2Array([Vector2(14, 0), Vector2(14, 6)])
	teeth2.width = 3.0
	teeth2.default_color = Color(1.0, 0.85, 0.2)
	visual.add_child(teeth2)
	
	area.add_child(visual)

	var tw := area.create_tween().set_loops()
	tw.tween_property(visual, "position:y", -12.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(visual, "position:y", -6.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	area.collision_layer = 0
	area.collision_mask = 1
	area.body_entered.connect(_on_key_collected.bind(area))

	add_child(area)
	level_nodes.append(area)

func _on_key_collected(body: Node, area: Area2D) -> void:
	if body != current_character and body != rob and body != bog:
		return
	if not is_instance_valid(area):
		return
		
	var lock_id: int = area.get_meta("lock_id")
	if not _collected_keys.has(lock_id):
		_collected_keys.append(lock_id)
		hud.update_keys(_collected_keys.size())
		SoundManager.play_sfx("collect")
		_spawn_star_burst_particles(area.global_position)
		
		var tw := area.create_tween().set_parallel(true)
		tw.tween_property(area, "scale", Vector2(2.0, 2.0), 0.25)
		tw.tween_property(area, "modulate:a", 0.0, 0.25)
		tw.chain().tween_callback(area.queue_free)
		level_nodes.erase(area)

func _create_lock(lock_id: int, x: float, y: float, w: float, h: float) -> void:
	var block := StaticBody2D.new()
	block.position = Vector2(x + w / 2.0, y + h / 2.0)
	block.collision_layer = 1
	block.collision_mask = 1
	block.set_meta("lock_id", lock_id)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	shape.shape = rect
	block.add_child(shape)

	var visual := ColorRect.new()
	visual.size = Vector2(w, h)
	visual.position = Vector2(-w / 2.0, -h / 2.0)
	visual.color = Color(0.40, 0.20, 0.20)
	visual.name = "Visual"
	block.add_child(visual)

	var border := ColorRect.new()
	border.size = Vector2(w, 4)
	border.position = Vector2(-w / 2.0, -h / 2.0)
	border.color = Color(0.60, 0.30, 0.30)
	block.add_child(border)

	# Fechadura (Keyhole) indicativo
	var keyhole := Node2D.new()
	
	var keyhole_bg_top := Polygon2D.new()
	var bg_pts: PackedVector2Array = PackedVector2Array()
	for i in range(16):
		var angle: float = float(i) * PI * 2.0 / 16.0
		bg_pts.append(Vector2(cos(angle), sin(angle)) * 8.0)
	keyhole_bg_top.polygon = bg_pts
	keyhole_bg_top.color = Color(0.9, 0.75, 0.2)
	keyhole_bg_top.position = Vector2(0, -2)
	keyhole.add_child(keyhole_bg_top)
	
	var keyhole_bg_bot := ColorRect.new()
	keyhole_bg_bot.size = Vector2(10, 10)
	keyhole_bg_bot.position = Vector2(-5, 2)
	keyhole_bg_bot.color = Color(0.9, 0.75, 0.2)
	keyhole.add_child(keyhole_bg_bot)

	var keyhole_hole_top := Polygon2D.new()
	var hole_pts: PackedVector2Array = PackedVector2Array()
	for i in range(16):
		var angle: float = float(i) * PI * 2.0 / 16.0
		hole_pts.append(Vector2(cos(angle), sin(angle)) * 4.0)
	keyhole_hole_top.polygon = hole_pts
	keyhole_hole_top.color = Color(0.1, 0.1, 0.1)
	keyhole_hole_top.position = Vector2(0, -2)
	keyhole.add_child(keyhole_hole_top)
	
	var keyhole_hole_bot := ColorRect.new()
	keyhole_hole_bot.size = Vector2(4, 6)
	keyhole_hole_bot.position = Vector2(-2, 0)
	keyhole_hole_bot.color = Color(0.1, 0.1, 0.1)
	keyhole.add_child(keyhole_hole_bot)
	
	block.add_child(keyhole)

	# Área para detectar toque
	var area := Area2D.new()
	area.name = "Area"
	var area_shape := CollisionShape2D.new()
	var area_rect := RectangleShape2D.new()
	area_rect.size = Vector2(w + 4, h + 4)
	area_shape.shape = area_rect
	area.add_child(area_shape)
	area.collision_layer = 0
	area.collision_mask = 1
	block.add_child(area)

	var block_script = GDScript.new()
	block_script.source_code = "extends StaticBody2D\n\nvar _broken := false\nvar main_scene: Node2D\nvar lock_id: int\n\nfunc _ready():\n	main_scene = get_parent()\n	lock_id = get_meta(\"lock_id\")\n	var area = get_node(\"Area\")\n	area.body_entered.connect(_on_touch)\n\nfunc _on_touch(body):\n	if _broken or not (body is CharacterBase):\n		return\n	if main_scene._collected_keys.has(lock_id):\n		open_lock()\n\nfunc open_lock():\n	if _broken:\n		return\n	_broken = true\n	collision_layer = 0\n	collision_mask = 0\n	SoundManager.play_sfx(\"impact\")\n	if main_scene and main_scene.has_method(\"apply_shake\"):\n		main_scene.apply_shake(6.0)\n	if main_scene and main_scene.has_method(\"_spawn_dust\"):\n		main_scene._spawn_dust(global_position, Color(0.8, 0.7, 0.4), 24, -40.0)\n	var tw = create_tween().set_parallel(true)\n	tw.tween_property(self, \"scale\", Vector2(1.3, 1.3), 0.15)\n	tw.tween_property(self, \"modulate:a\", 0.0, 0.15)\n	await get_tree().create_timer(0.15).timeout\n	queue_free()"
	block_script.reload()
	block.set_script(block_script)

	add_child(block)
	level_nodes.append(block)

func _create_lever(gate_id: int, x: float, y: float, w: float, h: float) -> void:
	var area := Area2D.new()
	area.position = Vector2(x + w / 2.0, y + h / 2.0)
	area.name = "Lever_" + str(gate_id)
	area.set_meta("gate_id", gate_id)
	area.set_meta("w", w)
	
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w + 12, h + 12)
	shape.shape = rect
	area.add_child(shape)

	var visual: Node2D = Node2D.new()
	visual.name = "Visual"
	visual.position = Vector2(-w / 2.0, -h / 2.0)
	area.add_child(visual)

	var base_rect: Polygon2D = Polygon2D.new()
	base_rect.polygon = PackedVector2Array([
		Vector2(0, h),
		Vector2(w, h),
		Vector2(w - 6.0, h * 0.6),
		Vector2(6.0, h * 0.6)
	])
	base_rect.color = Color(0.25, 0.25, 0.3)
	visual.add_child(base_rect)

	var haste_pivot: Node2D = Node2D.new()
	haste_pivot.name = "HastePivot"
	haste_pivot.position = Vector2(w / 2.0, h * 0.7)
	haste_pivot.rotation_degrees = -45.0
	visual.add_child(haste_pivot)

	var haste: Line2D = Line2D.new()
	haste.width = 6.0
	haste.default_color = Color(0.6, 0.6, 0.65)
	haste.points = PackedVector2Array([Vector2(0, 0), Vector2(0, -h * 0.6)])
	haste_pivot.add_child(haste)
	
	var handle: Polygon2D = Polygon2D.new()
	handle.name = "Handle"
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(12):
		var ang: float = float(i) * PI / 6.0
		pts.append(Vector2(cos(ang), sin(ang)) * 8.0)
	handle.polygon = pts
	handle.position = Vector2(0, -h * 0.6)
	handle.color = Color(0.9, 0.2, 0.2)
	haste_pivot.add_child(handle)

	area.collision_layer = 0
	area.collision_mask = 1

	var lever_script = GDScript.new()
	lever_script.source_code = "extends Area2D\n\nvar _is_on := false\nvar gate_id: int\nvar main_scene: Node2D\nvar haste_pivot: Node2D\nvar handle: Polygon2D\nvar cooldown := 0.0\n\nfunc _ready():\n	main_scene = get_parent()\n	gate_id = get_meta(\"gate_id\")\n	haste_pivot = get_node(\"Visual/HastePivot\")\n	handle = haste_pivot.get_node(\"Handle\")\n	body_entered.connect(_on_body_entered)\n\nfunc _process(delta):\n	if cooldown > 0:\n		cooldown -= delta\n\nfunc _on_body_entered(body):\n	if not (body is CharacterBase) or cooldown > 0:\n		return\n	cooldown = 0.5\n	_is_on = not _is_on\n	SoundManager.play_sfx(\"switch\")\n	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)\n	if _is_on:\n		tw.tween_property(haste_pivot, \"rotation_degrees\", 45.0, 0.25)\n		handle.color = Color(0.2, 0.9, 0.3)\n	else:\n		tw.tween_property(haste_pivot, \"rotation_degrees\", -45.0, 0.25)\n		handle.color = Color(0.9, 0.2, 0.2)\n	if main_scene and main_scene.has_method(\"_set_gates_active\"):\n		main_scene._set_gates_active(gate_id, _is_on)"
	lever_script.reload()
	area.set_script(lever_script)

	add_child(area)
	level_nodes.append(area)

func _create_secret_exit(x: float, y: float, w: float, h: float, target_name: String) -> void:
	var area = Area2D.new()
	area.position = Vector2(x + w / 2.0, y + h / 2.0)
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(w, h)
	shape.shape = rect
	area.add_child(shape)
	area.set_meta("target_name", target_name)
	area.collision_layer = 0
	area.collision_mask = 1
	
	var exit_script = GDScript.new()
	exit_script.source_code = "extends Area2D\n\nvar main_scene: Node2D\nvar target_name: String\n\nfunc _ready():\n	main_scene = get_parent()\n	target_name = get_meta(\"target_name\")\n	body_entered.connect(_on_touch)\n\nfunc _on_touch(body):\n	if (body == main_scene.rob or body == main_scene.bog) and not main_scene.is_exiting and not main_scene.hud.fading and not main_scene.hud.transitioning:\n		main_scene.is_exiting = true\n		if main_scene.rob:\n			main_scene.rob.velocity = Vector2.ZERO\n		if main_scene.bog:\n			main_scene.bog.velocity = Vector2.ZERO\n		SoundManager.play_sfx(\"collect\")\n		var tween := main_scene.create_tween().bind_node(main_scene)\n		tween.set_ignore_time_scale(true)\n		tween.tween_property(Engine, \"time_scale\", 0.2, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)\n		tween.tween_property(main_scene.camera, \"zoom\", Vector2(1.25, 1.25), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)\n		tween.tween_interval(0.8)\n		tween.tween_callback(func():\n			main_scene.is_exiting = false\n			Engine.time_scale = 1.0\n			var from_name = GameManager.get_current_level().get(\"name\", \"\")\n			if GameManager.goto_level_by_name(target_name):\n				var to_name = GameManager.get_current_level().get(\"name\", \"\")\n				SoundManager.stop_ambient()\n				main_scene.hud.start_level_transition(from_name, to_name, main_scene._load_next_level)\n			else:\n				print(\"[ERROR] Nível secreto não encontrado:\", target_name)\n		)\n"
	exit_script.reload()
	area.set_script(exit_script)
	
	add_child(area)
	level_nodes.append(area)

func _setup_dark_mode() -> void:
	_canvas_mod = CanvasModulate.new()
	_canvas_mod.color = Color(0.02, 0.02, 0.05)
	add_child(_canvas_mod)
	level_nodes.append(_canvas_mod)
	
	for character in [rob, bog]:
		if not is_instance_valid(character):
			continue
		var light = PointLight2D.new()
		var tex = GradientTexture2D.new()
		tex.fill = GradientTexture2D.FILL_RADIAL
		tex.fill_from = Vector2(0.5, 0.5)
		tex.fill_to = Vector2(0.5, 0.0)
		var grad = Gradient.new()
		grad.colors = PackedColorArray([Color.WHITE, Color.TRANSPARENT])
		grad.offsets = PackedFloat32Array([0.0, 1.0])
		tex.gradient = grad
		tex.width = 400
		tex.height = 400
		light.texture = tex
		light.color = Color(1.0, 0.95, 0.8)
		light.energy = 1.0
		light.blend_mode = Light2D.BLEND_MODE_ADD
		light.position = Vector2(0, -10)
		character.add_child(light)
		_character_lights.append(light)
		light.set_meta("dynamic_light", true)

func _create_light_switch(x: float, y: float, w: float, h: float) -> void:
	var area = Area2D.new()
	area.position = Vector2(x + w / 2.0, y + h / 2.0)
	
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w + 12, h + 12)
	shape.shape = rect
	area.add_child(shape)

	var visual: Node2D = Node2D.new()
	visual.name = "Visual"
	visual.position = Vector2(-w / 2.0, -h / 2.0)
	area.add_child(visual)

	var base_rect: Polygon2D = Polygon2D.new()
	base_rect.polygon = PackedVector2Array([
		Vector2(0, h),
		Vector2(w, h),
		Vector2(w - 6.0, h * 0.6),
		Vector2(6.0, h * 0.6)
	])
	base_rect.color = Color(0.25, 0.25, 0.3)
	visual.add_child(base_rect)

	var haste_pivot: Node2D = Node2D.new()
	haste_pivot.name = "HastePivot"
	haste_pivot.position = Vector2(w / 2.0, h * 0.7)
	haste_pivot.rotation_degrees = -45.0
	visual.add_child(haste_pivot)

	var haste: Line2D = Line2D.new()
	haste.width = 6.0
	haste.default_color = Color(0.6, 0.6, 0.65)
	haste.points = PackedVector2Array([Vector2(0, 0), Vector2(0, -h * 0.6)])
	haste_pivot.add_child(haste)
	
	var handle: Polygon2D = Polygon2D.new()
	handle.name = "Handle"
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(12):
		var ang: float = float(i) * PI / 6.0
		pts.append(Vector2(cos(ang), sin(ang)) * 8.0)
	handle.polygon = pts
	handle.position = Vector2(0, -h * 0.6)
	handle.color = Color(0.9, 0.2, 0.2)
	haste_pivot.add_child(handle)

	area.collision_layer = 0
	area.collision_mask = 1
	
	var switch_script = GDScript.new()
	switch_script.source_code = "extends Area2D\n\nvar main_scene: Node2D\nvar activated := false\nvar haste_pivot: Node2D\nvar handle: Polygon2D\n\nfunc _ready():\n	main_scene = get_parent()\n	haste_pivot = get_node(\"Visual/HastePivot\")\n	handle = haste_pivot.get_node(\"Handle\")\n	body_entered.connect(_on_touch)\n\nfunc _on_touch(body):\n	if activated:\n		return\n	if (body == main_scene.rob or body == main_scene.bog):\n		activated = true\n		SoundManager.play_sfx(\"switch\")\n		var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)\n		tw.tween_property(haste_pivot, \"rotation_degrees\", 45.0, 0.25)\n		handle.color = Color(0.9, 0.9, 0.3)\n		if main_scene._canvas_mod:\n			var tw_c = main_scene.create_tween()\n			tw_c.tween_property(main_scene._canvas_mod, \"color\", Color.WHITE, 1.5)\n		for light in main_scene._character_lights:\n			if is_instance_valid(light):\n				var tw_l = main_scene.create_tween()\n				tw_l.tween_property(light, \"energy\", 0.0, 1.5)\n"
	switch_script.reload()
	area.set_script(switch_script)
	
	add_child(area)
	level_nodes.append(area)
