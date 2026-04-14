extends CanvasLayer
class_name GameHUD

## HUD do jogo Lost & Loopy
## Responsavel por: painel principal, intro de fase, fade de transicao e checkpoint.

# --- Painel superior ---
var _lbl_phase:    Label
var _lbl_name:     Label
var _lbl_modifier: Label
var _dots:         Array = []   # 5 Labels de progresso
var _rob_bg:       ColorRect
var _bog_bg:       ColorRect
var _lbl_rob:      Label
var _lbl_bog:      Label
var _hearts:       Array = []   # 4 Labels de coracao
var _pulse_tween: Tween = null
var _rob_was_ready: bool  = false
var _bog_was_ready: bool  = false
var _rob_flash_tween: Tween = null
var _bog_flash_tween: Tween = null

# --- Intro de fase ---
var _intro_overlay:   Panel
var _intro_lbl_phase: Label
var _intro_lbl_name:  Label
var _intro_lbl_desc:  Label
var _intro_lbl_mod:   Label
var _intro_timer:     float = 0.0
var showing_intro:    bool  = false

# --- Habilidade cooldown ---
var _rob_ability_bg:   ColorRect
var _rob_ability_fill: ColorRect
var _bog_ability_bg:   ColorRect
var _bog_ability_fill: ColorRect

# --- Checkpoint ---
var _checkpoint_lbl:   Label
var _checkpoint_timer: float = 0.0

# --- Fade de transicao ---
var _fade_rect:     ColorRect
var fading:         bool     = false
var _fade_alpha:    float    = 0.0
var _fade_dir:      int      = 0
var _fade_callback: Callable

const FADE_SPEED:      float = 2.5
const INTRO_DURATION:  float = 3.5

const COLOR_ROB  := Color(0.40, 0.75, 1.00)
const COLOR_BOG  := Color(0.35, 1.00, 0.55)
const COLOR_DIM  := Color(0.25, 0.25, 0.30)
const COLOR_GOLD := Color(1.00, 0.85, 0.25)
const COLOR_HEART_ON  := Color(0.95, 0.20, 0.30)
const COLOR_HEART_OFF := Color(0.22, 0.12, 0.15)

# ============================================================

func _ready() -> void:
	layer = 10
	_build_top_panel()
	_build_intro_overlay()
	_build_fade()
	_build_checkpoint_label()

func _process(delta: float) -> void:
	_tick_intro(delta)
	_tick_fade(delta)
	_tick_checkpoint(delta)

# ============================================================
# PAINEL SUPERIOR
# ============================================================

func _build_top_panel() -> void:
	var bg := ColorRect.new()
	bg.size     = Vector2(1152, 68)
	bg.position = Vector2.ZERO
	bg.color    = Color(0.04, 0.05, 0.10, 0.93)
	add_child(bg)

	var border := ColorRect.new()
	border.size     = Vector2(1152, 2)
	border.position = Vector2(0, 66)
	border.color    = Color(0.20, 0.25, 0.45, 0.80)
	add_child(border)

	# ---- Fase (esquerda) ----
	_lbl_phase = Label.new()
	_lbl_phase.position = Vector2(14, 5)
	_lbl_phase.add_theme_font_size_override("font_size", 11)
	_lbl_phase.add_theme_color_override("font_color", Color(0.45, 0.70, 1.0))
	add_child(_lbl_phase)

	_lbl_name = Label.new()
	_lbl_name.position = Vector2(14, 20)
	_lbl_name.add_theme_font_size_override("font_size", 24)
	_lbl_name.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	add_child(_lbl_name)

	_lbl_modifier = Label.new()
	_lbl_modifier.position = Vector2(14, 48)
	_lbl_modifier.add_theme_font_size_override("font_size", 12)
	_lbl_modifier.add_theme_color_override("font_color", COLOR_GOLD)
	add_child(_lbl_modifier)

	# ---- Progresso (centro) ----
	var lbl_prog := Label.new()
	lbl_prog.text                 = "P R O G R E S S O"
	lbl_prog.position             = Vector2(460, 5)
	lbl_prog.size                 = Vector2(232, 18)
	lbl_prog.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_prog.add_theme_font_size_override("font_size", 9)
	lbl_prog.add_theme_color_override("font_color", Color(0.30, 0.30, 0.38))
	add_child(lbl_prog)

	for i in range(5):
		var dot := Label.new()
		dot.text                 = "●"
		dot.position             = Vector2(468 + i * 38, 22)
		dot.add_theme_font_size_override("font_size", 22)
		dot.add_theme_color_override("font_color", COLOR_DIM)
		add_child(dot)
		_dots.append(dot)

	for xpos in [452, 668]:
		var sep := ColorRect.new()
		sep.size     = Vector2(1, 50)
		sep.position = Vector2(xpos, 9)
		sep.color    = Color(0.20, 0.22, 0.35, 0.60)
		add_child(sep)

	# ---- Personagens (direita) ----
	var lbl_char := Label.new()
	lbl_char.text                 = "P E R S O N A G E M"
	lbl_char.position             = Vector2(685, 5)
	lbl_char.size                 = Vector2(220, 18)
	lbl_char.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_char.add_theme_font_size_override("font_size", 9)
	lbl_char.add_theme_color_override("font_color", Color(0.30, 0.30, 0.38))
	add_child(lbl_char)

	_rob_bg = ColorRect.new()
	_rob_bg.size     = Vector2(96, 30)
	_rob_bg.position = Vector2(685, 24)
	_rob_bg.color    = Color(0.08, 0.16, 0.28)
	add_child(_rob_bg)

	_lbl_rob = Label.new()
	_lbl_rob.text                 = "ROB"
	_lbl_rob.position             = Vector2(685, 24)
	_lbl_rob.size                 = Vector2(96, 30)
	_lbl_rob.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_rob.add_theme_font_size_override("font_size", 16)
	_lbl_rob.add_theme_color_override("font_color", COLOR_ROB)
	add_child(_lbl_rob)

	_bog_bg = ColorRect.new()
	_bog_bg.size     = Vector2(96, 30)
	_bog_bg.position = Vector2(789, 24)
	_bog_bg.color    = Color(0.08, 0.22, 0.12)
	add_child(_bog_bg)

	_lbl_bog = Label.new()
	_lbl_bog.text                 = "BOG"
	_lbl_bog.position             = Vector2(789, 24)
	_lbl_bog.size                 = Vector2(96, 30)
	_lbl_bog.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_bog.add_theme_font_size_override("font_size", 16)
	_lbl_bog.add_theme_color_override("font_color", COLOR_BOG)
	add_child(_lbl_bog)

	var lbl_tab := Label.new()
	lbl_tab.text                 = "[ TAB ] trocar   [ Z ] habilidade"
	lbl_tab.position             = Vector2(685, 55)
	lbl_tab.size                 = Vector2(200, 14)
	lbl_tab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_tab.add_theme_font_size_override("font_size", 9)
	lbl_tab.add_theme_color_override("font_color", Color(0.28, 0.28, 0.34))
	add_child(lbl_tab)

	# Barras de cooldown da habilidade (abaixo dos boxes)
	# ROB
	_rob_ability_bg        = ColorRect.new()
	_rob_ability_bg.size   = Vector2(96, 4)
	_rob_ability_bg.position = Vector2(685, 62)
	_rob_ability_bg.color  = Color(0.12, 0.12, 0.16)
	add_child(_rob_ability_bg)

	_rob_ability_fill        = ColorRect.new()
	_rob_ability_fill.size   = Vector2(96, 4)
	_rob_ability_fill.position = Vector2(685, 62)
	_rob_ability_fill.color  = Color(0.25, 0.88, 1.0)
	add_child(_rob_ability_fill)

	# BOG
	_bog_ability_bg        = ColorRect.new()
	_bog_ability_bg.size   = Vector2(96, 4)
	_bog_ability_bg.position = Vector2(789, 62)
	_bog_ability_bg.color  = Color(0.12, 0.12, 0.16)
	add_child(_bog_ability_bg)

	_bog_ability_fill        = ColorRect.new()
	_bog_ability_fill.size   = Vector2(96, 4)
	_bog_ability_fill.position = Vector2(789, 62)
	_bog_ability_fill.color  = Color(1.0, 0.62, 0.22)
	add_child(_bog_ability_fill)

	# ---- Vidas: 4 coracoes ----
	var sep_vidas := ColorRect.new()
	sep_vidas.size     = Vector2(1, 50)
	sep_vidas.position = Vector2(908, 9)
	sep_vidas.color    = Color(0.20, 0.22, 0.35, 0.60)
	add_child(sep_vidas)

	var lbl_vidas := Label.new()
	lbl_vidas.text                 = "V I D A S"
	lbl_vidas.position             = Vector2(916, 5)
	lbl_vidas.size                 = Vector2(228, 18)
	lbl_vidas.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_vidas.add_theme_font_size_override("font_size", 9)
	lbl_vidas.add_theme_color_override("font_color", Color(0.30, 0.30, 0.38))
	add_child(lbl_vidas)

	# 4 coracoes: posicoes 920, 966, 1012, 1058
	for i in range(4):
		var heart := Label.new()
		heart.text                 = "♥"
		heart.position             = Vector2(920 + i * 46, 18)
		heart.size                 = Vector2(46, 40)
		heart.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		heart.add_theme_font_size_override("font_size", 28)
		heart.add_theme_color_override("font_color", COLOR_HEART_ON)
		add_child(heart)
		_hearts.append(heart)

# ============================================================
# METODOS DE ATUALIZACAO
# ============================================================

func update_level_info(level: Dictionary, idx: int, total: int) -> void:
	_lbl_phase.text    = "FASE  %d / %d" % [idx + 1, total]
	_lbl_name.text     = level["name"]
	_lbl_modifier.text = level["modifier_hint"]

	for i in range(_dots.size()):
		var dot: Label = _dots[i]
		if i < idx:
			dot.add_theme_color_override("font_color", Color(0.25, 0.80, 0.40))
		elif i == idx:
			dot.add_theme_color_override("font_color", COLOR_GOLD)
		else:
			dot.add_theme_color_override("font_color", COLOR_DIM)

func update_ability(rob_ratio: float, bog_ratio: float) -> void:
	_rob_ability_fill.size.x = 96.0 * clamp(rob_ratio, 0.0, 1.0)
	_bog_ability_fill.size.x = 96.0 * clamp(bog_ratio, 0.0, 1.0)

	var rob_ready := rob_ratio >= 1.0
	var bog_ready := bog_ratio >= 1.0

	# Cores normais (cheio vs carregando)
	_rob_ability_fill.color = Color(0.25, 0.88, 1.0)  if rob_ready else Color(0.18, 0.42, 0.55)
	_bog_ability_fill.color = Color(1.0,  0.62, 0.22) if bog_ready else Color(0.45, 0.28, 0.10)

	# Flash do Rob: só dispara na transição não-pronto → pronto
	if rob_ready and not _rob_was_ready:
		if _rob_flash_tween:
			_rob_flash_tween.kill()
		_rob_ability_fill.color = Color.WHITE
		_rob_flash_tween = create_tween()
		_rob_flash_tween.tween_property(_rob_ability_fill, "color", Color(0.25, 0.88, 1.0), 0.45)\
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	# Flash do Bog
	if bog_ready and not _bog_was_ready:
		if _bog_flash_tween:
			_bog_flash_tween.kill()
		_bog_ability_fill.color = Color.WHITE
		_bog_flash_tween = create_tween()
		_bog_flash_tween.tween_property(_bog_ability_fill, "color", Color(1.0, 0.62, 0.22), 0.45)\
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	_rob_was_ready = rob_ready
	_bog_was_ready = bog_ready
	
func update_character(rob_active: bool) -> void:
	if rob_active:
		_rob_bg.color = Color(0.10, 0.22, 0.40)
		_bog_bg.color = Color(0.06, 0.10, 0.07)
		_lbl_rob.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		_lbl_bog.add_theme_color_override("font_color", Color(0.28, 0.42, 0.30))
	else:
		_rob_bg.color = Color(0.06, 0.10, 0.18)
		_bog_bg.color = Color(0.10, 0.28, 0.16)
		_lbl_rob.add_theme_color_override("font_color", Color(0.28, 0.38, 0.55))
		_lbl_bog.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

func update_lives(lives: int) -> void:
	# Para pulse anterior
	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null

	for i in range(_hearts.size()):
		var heart: Label = _hearts[i]
		heart.pivot_offset = Vector2(23, 20)  # centro do coração
		heart.scale = Vector2.ONE             # reseta escala
		if i < lives:
			heart.add_theme_color_override("font_color", COLOR_HEART_ON)
		else:
			heart.add_theme_color_override("font_color", COLOR_HEART_OFF)

	# Pulsa o último coração restante quando lives == 1
	if lives == 1:
		var last_heart: Label = _hearts[0]
		_pulse_tween = create_tween().set_loops()
		_pulse_tween.tween_property(last_heart, "scale", Vector2(1.28, 1.28), 0.38)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_pulse_tween.tween_property(last_heart, "scale", Vector2.ONE, 0.38)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
# ============================================================
# CHECKPOINT NOTIFICATION
# ============================================================

func _build_checkpoint_label() -> void:
	_checkpoint_lbl          = Label.new()
	_checkpoint_lbl.text     = "✓  Checkpoint!"
	_checkpoint_lbl.position = Vector2(390, 82)
	_checkpoint_lbl.size     = Vector2(380, 36)
	_checkpoint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_checkpoint_lbl.add_theme_font_size_override("font_size", 20)
	_checkpoint_lbl.add_theme_color_override("font_color", Color(0.25, 1.0, 0.45))
	_checkpoint_lbl.modulate.a = 0.0
	add_child(_checkpoint_lbl)

func show_checkpoint_notification() -> void:
	_checkpoint_timer          = 2.2
	_checkpoint_lbl.modulate.a = 1.0

func _tick_checkpoint(delta: float) -> void:
	if _checkpoint_timer <= 0.0:
		return
	_checkpoint_timer -= delta
	if _checkpoint_timer < 0.7:
		_checkpoint_lbl.modulate.a = clamp(_checkpoint_timer / 0.7, 0.0, 1.0)
	if _checkpoint_timer <= 0.0:
		_checkpoint_lbl.modulate.a = 0.0

# ============================================================
# INTRO DE FASE
# ============================================================

func _build_intro_overlay() -> void:
	_intro_overlay              = Panel.new()
	_intro_overlay.size         = Vector2(1152, 648)
	_intro_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intro_overlay.visible      = false

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.04, 0.09, 0.92)
	_intro_overlay.add_theme_stylebox_override("panel", style)

	for y_pos in [0, 645]:
		var stripe := ColorRect.new()
		stripe.size     = Vector2(1152, 3)
		stripe.position = Vector2(0, y_pos)
		stripe.color    = Color(0.25, 0.80, 0.40, 0.70)
		_intro_overlay.add_child(stripe)

	_intro_lbl_phase = Label.new()
	_intro_lbl_phase.position             = Vector2(0, 155)
	_intro_lbl_phase.size                 = Vector2(1152, 32)
	_intro_lbl_phase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_intro_lbl_phase.add_theme_font_size_override("font_size", 16)
	_intro_lbl_phase.add_theme_color_override("font_color", Color(0.45, 0.70, 1.0, 0.85))
	_intro_overlay.add_child(_intro_lbl_phase)

	_intro_lbl_name = Label.new()
	_intro_lbl_name.position             = Vector2(0, 188)
	_intro_lbl_name.size                 = Vector2(1152, 80)
	_intro_lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_intro_lbl_name.add_theme_font_size_override("font_size", 56)
	_intro_lbl_name.add_theme_color_override("font_color", Color(0.95, 0.96, 1.0))
	_intro_overlay.add_child(_intro_lbl_name)

	var sep := ColorRect.new()
	sep.size     = Vector2(500, 2)
	sep.position = Vector2(326, 285)
	sep.color    = Color(0.25, 0.80, 0.40, 0.35)
	_intro_overlay.add_child(sep)

	_intro_lbl_desc = Label.new()
	_intro_lbl_desc.position             = Vector2(130, 296)
	_intro_lbl_desc.size                 = Vector2(892, 44)
	_intro_lbl_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_intro_lbl_desc.add_theme_font_size_override("font_size", 20)
	_intro_lbl_desc.add_theme_color_override("font_color", Color(0.72, 0.72, 0.82))
	_intro_overlay.add_child(_intro_lbl_desc)

	var mod_bg := ColorRect.new()
	mod_bg.size     = Vector2(700, 52)
	mod_bg.position = Vector2(226, 354)
	mod_bg.color    = Color(0.12, 0.10, 0.04, 0.80)
	_intro_overlay.add_child(mod_bg)

	_intro_lbl_mod = Label.new()
	_intro_lbl_mod.position             = Vector2(226, 354)
	_intro_lbl_mod.size                 = Vector2(700, 52)
	_intro_lbl_mod.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_intro_lbl_mod.add_theme_font_size_override("font_size", 28)
	_intro_lbl_mod.add_theme_color_override("font_color", COLOR_GOLD)
	_intro_overlay.add_child(_intro_lbl_mod)

	var skip := Label.new()
	skip.text                 = "Pressione  ESPAÇO  para começar"
	skip.position             = Vector2(150, 456)
	skip.size                 = Vector2(852, 28)
	skip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skip.add_theme_font_size_override("font_size", 15)
	skip.add_theme_color_override("font_color", Color(0.35, 0.35, 0.42))
	_intro_overlay.add_child(skip)

	add_child(_intro_overlay)

func show_intro(level: Dictionary, level_index: int) -> void:
	showing_intro  = true
	_intro_timer   = INTRO_DURATION
	_intro_overlay.modulate.a = 1.0

	var total := GameManager.get_level_count()
	_intro_lbl_phase.text = "—  FASE  %d  DE  %d  —" % [level_index + 1, total]
	_intro_lbl_name.text  = level["name"]
	_intro_lbl_desc.text  = level["description"]
	_intro_lbl_mod.text   = level["modifier_hint"]
	_intro_overlay.visible = true

func _tick_intro(delta: float) -> void:
	if not showing_intro:
		return
	_intro_timer -= delta

	if _intro_timer <= 0.6:
		_intro_overlay.modulate.a = clamp(_intro_timer / 0.6, 0.0, 1.0)

	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		_intro_timer = 0.0

	if _intro_timer <= 0.0:
		showing_intro             = false
		_intro_overlay.visible    = false
		_intro_overlay.modulate.a = 1.0

# ============================================================
# FADE DE TRANSICAO
# ============================================================

func _build_fade() -> void:
	_fade_rect              = ColorRect.new()
	_fade_rect.size         = Vector2(1152, 648)
	_fade_rect.color        = Color(0, 0, 0, 1)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade_rect)

## direction: 1 = escurece (fade in), -1 = clareia (fade out)
func start_fade(direction: int, callback: Callable) -> void:
	fading         = true
	_fade_dir      = direction
	_fade_alpha    = 0.0 if direction == 1 else 1.0
	_fade_callback = callback

func _tick_fade(delta: float) -> void:
	if not fading:
		_fade_rect.color.a = 0.0
		return

	_fade_alpha        += _fade_dir * delta * FADE_SPEED
	_fade_rect.color.a  = clamp(_fade_alpha, 0.0, 1.0)

	var done := (_fade_dir == 1 and _fade_alpha >= 1.0) or \
				(_fade_dir == -1 and _fade_alpha <= 0.0)
	if done:
		fading = false
		if _fade_callback.is_valid():
			_fade_callback.call()
