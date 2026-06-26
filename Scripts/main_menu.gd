extends Control

## Main Menu - Tela de titulo do Lost & Loopy
## Exibe jornal narrativo antes de iniciar o jogo.

@export var background_image: Texture2D

@export_group("Newspaper Settings")
@export var newspaper_font: Font
@export var newspaper_letter_spacing: int = 1
@export var newspaper_line_spacing: int = 4
@export var newspaper_title: String = "O DIÁRIO DA CIDADE"
@export var newspaper_subtitle: String = "Edição Especial  ·  Cidade Urbana, 2026  ·  Número 4.521"
@export var newspaper_headline: String = "GAROTO DESAPARECE APÓS TOMAR CHÁ MISTERIOSO"
@export var newspaper_subheadline: String = "Jovem saiu do Café Loop completamente desorientado após receber chá de senhora misteriosa"
@export var newspaper_author: String = "Por nosso correspondente especial  ·  Ontem, às 09h47"
@export_multiline var newspaper_paragraphs: Array[String] = [
	"Moradores da região ficaram surpresos ao ver o\njovem Loopy sair do tradicional Café Loop visivelmente\nconfuso, com olhar distante e passos completamente\nerrantes pelas ruas do bairro.",
	"Segundo testemunhas, uma senhora de aparência\nincomum havia lhe servido um chá de ervas de origem\ndesconhecida, dizendo que era \"para clarear a mente\".\nNinguém sabe quem era a misteriosa mulher.",
	"Loopy, normalmente bem-humorado e comunicativo,\ncaminhou pelas ruas sem destino aparente, ignorando\ncompletamente aqueles ao seu redor.\n\"Parecia estar em outro mundo\", disse uma moradora.",
	"Seus amigos inseparáveis Rob e Bog, ao ficarem\nsabendo do ocorrido, partiram imediatamente em\nbusca do amigo perdido pelos bairros da cidade."
]
@export var newspaper_photo_caption: String = "Loopy, visto pela última vez saindo do Café Loop"
@export var newspaper_box_title: String = "QUEM É LOOPY?"
@export_multiline var newspaper_box_text: String = "Jovem de personalidade descontraída,\nconhecido pelo bom humor e pelo hábito\nde ler o jornal e tomar chá todas as manhãs\nno banco da praça em frente ao Café Loop."

var title_label: Label
var start_button: Button
var new_game_button: Button
var quit_button: Button
var bg: Control # <-- Alterado de ColorRect para Control genérico
var time: float = 0.0
var _newspaper_visible: bool = false
var _intro_visible: bool = false

func _ready() -> void:
	_build_ui()
	SoundManager.play_bgm("res://backgroundmusicforvideos-gaming-game-minecraft-background-music-372242.ogg")

func _process(delta: float) -> void:
	time += delta
	if title_label:
		title_label.rotation = sin(time * 1.5) * 0.03
		title_label.position.y = 100 + sin(time * 2.0) * 5.0
	if _newspaper_visible:
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
			_newspaper_visible = false
			SoundManager.play_sfx("switch")
			_build_character_intro()
	elif _intro_visible:
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
			_start_game()

# ============================================================
# CONSTRUCAO DO MENU
# ============================================================

# ============================================================
# CONSTRUCAO DO MENU
# ============================================================

func _build_ui() -> void:
	# 1. Checa se você colocou uma imagem no Inspector
	if background_image != null:
		var bg_tex = TextureRect.new()
		bg_tex.texture = background_image
		bg_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg_tex.stretch_mode = TextureRect.STRETCH_SCALE
		bg = bg_tex
		add_child(bg)
	else:
		# 2. Fallback: Se não houver imagem, desenha o fundo original com estrelas
		var bg_color = ColorRect.new()
		bg_color.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_color.color = Color(0.08, 0.10, 0.18)
		bg = bg_color
		add_child(bg)

		for i in range(30):
			var star := ColorRect.new()
			star.size     = Vector2(2, 2)
			star.position = Vector2(randf() * 1152, randf() * 648)
			star.color    = Color(1, 1, 1, randf() * 0.5 + 0.1)
			add_child(star)

	var center_box = Control.new()
	center_box.set_anchors_preset(Control.PRESET_CENTER)
	center_box.offset_left = -576
	center_box.offset_top = -324
	center_box.offset_right = 576
	center_box.offset_bottom = 324
	add_child(center_box)

	var btn_box := VBoxContainer.new()
	if GameManager.current_level_index > 0:
		btn_box.position = Vector2(426, 215)
	else:
		btn_box.position = Vector2(426, 260)
	btn_box.size     = Vector2(300, 200)
	btn_box.add_theme_constant_override("separation", 15)
	center_box.add_child(btn_box)

	start_button = Button.new()
	if GameManager.current_level_index > 0:
		start_button.text = "Continuar"
	else:
		start_button.text = "Jogar"
	start_button.custom_minimum_size = Vector2(300, 55)
	start_button.add_theme_font_size_override("font_size", 36)
	start_button.pressed.connect(_on_start)
	btn_box.add_child(start_button)
	_setup_button_sounds(start_button)

	if GameManager.current_level_index > 0:
		new_game_button = Button.new()
		new_game_button.text = "Novo Jogo"
		new_game_button.custom_minimum_size = Vector2(300, 45)
		new_game_button.add_theme_font_size_override("font_size", 20)
		new_game_button.pressed.connect(_on_new_game)
		btn_box.add_child(new_game_button)
		_setup_button_sounds(new_game_button)

	var tips_button := Button.new()
	tips_button.text = "Dicas"
	tips_button.custom_minimum_size = Vector2(300, 45)
	tips_button.add_theme_font_size_override("font_size", 20)
	tips_button.pressed.connect(_show_menu_help)
	btn_box.add_child(tips_button)
	_setup_button_sounds(tips_button)

	var options_button := Button.new()
	options_button.text = "Opções"
	options_button.custom_minimum_size = Vector2(300, 45)
	options_button.add_theme_font_size_override("font_size", 20)
	options_button.pressed.connect(_show_options_menu)
	btn_box.add_child(options_button)
	_setup_button_sounds(options_button)

	var credits_button := Button.new()
	credits_button.text = "Créditos"
	credits_button.custom_minimum_size = Vector2(300, 45)
	credits_button.add_theme_font_size_override("font_size", 20)
	credits_button.pressed.connect(_show_credits_menu)
	btn_box.add_child(credits_button)
	_setup_button_sounds(credits_button)

	quit_button = Button.new()
	quit_button.text = "Sair"
	quit_button.custom_minimum_size = Vector2(300, 45)
	quit_button.add_theme_font_size_override("font_size", 20)
	quit_button.pressed.connect(_on_quit)
	btn_box.add_child(quit_button)
	_setup_button_sounds(quit_button)


# ============================================================
# ACOES
# ============================================================

func _on_start() -> void:
	start_button.disabled = true
	if is_instance_valid(new_game_button):
		new_game_button.disabled = true
	quit_button.disabled  = true
	if GameManager.current_level_index > 0:
		_start_game()
	else:
		_build_newspaper()

var _confirm_overlay: Control = null

func _show_confirm_overlay(title_text: String, msg_text: String, yes_callback: Callable) -> void:
	if _confirm_overlay and is_instance_valid(_confirm_overlay):
		return

	_confirm_overlay = Control.new()
	_confirm_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_confirm_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.85)
	_confirm_overlay.add_child(dim)

	var center_box = Control.new()
	center_box.set_anchors_preset(Control.PRESET_CENTER)
	center_box.offset_left = -576
	center_box.offset_top = -324
	center_box.offset_right = 576
	center_box.offset_bottom = 324
	_confirm_overlay.add_child(center_box)

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
	title.text = title_text
	title.position = Vector2(376, 250)
	title.size = Vector2(400, 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30))
	center_box.add_child(title)

	var msg := Label.new()
	msg.text = msg_text
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
	btn_yes.pressed.connect(func():
		_close_confirm_overlay()
		yes_callback.call()
	)
	center_box.add_child(btn_yes)
	_setup_button_sounds(btn_yes)

	var btn_no := Button.new()
	btn_no.text = "Não"
	btn_no.position = Vector2(596, 340)
	btn_no.size = Vector2(150, 42)
	btn_no.add_theme_font_size_override("font_size", 18)
	btn_no.pressed.connect(_close_confirm_overlay)
	
	var resume_key = InputEventKey.new()
	resume_key.keycode = KEY_ESCAPE
	var resume_shortcut = Shortcut.new()
	resume_shortcut.events = [resume_key]
	btn_no.shortcut = resume_shortcut
	
	center_box.add_child(btn_no)
	_setup_button_sounds(btn_no)

func _close_confirm_overlay() -> void:
	if _confirm_overlay and is_instance_valid(_confirm_overlay):
		_confirm_overlay.queue_free()
	_confirm_overlay = null

func _on_new_game() -> void:
	_show_confirm_overlay("NOVO JOGO?", "Todo o progresso atual será apagado.", _do_new_game)

func _do_new_game() -> void:
	start_button.disabled = true
	if is_instance_valid(new_game_button):
		new_game_button.disabled = true
	quit_button.disabled  = true
	GameManager.reset_game()
	_build_newspaper()

func _on_quit() -> void:
	_show_confirm_overlay("SAIR DO JOGO?", "Deseja realmente fechar o jogo?", _do_quit)

func _do_quit() -> void:
	GameManager.save_game()
	get_tree().quit()

# ============================================================
# DICAS (acessível pelo botão do menu)
# ============================================================

var _menu_help_overlay: Control = null

func _show_menu_help() -> void:
	if _menu_help_overlay and is_instance_valid(_menu_help_overlay):
		return

	_menu_help_overlay = Control.new()
	_menu_help_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_menu_help_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.82)
	_menu_help_overlay.add_child(dim)

	var center_box = Control.new()
	center_box.name = "CenterBox"
	center_box.set_anchors_preset(Control.PRESET_CENTER)
	center_box.offset_left = -576
	center_box.offset_top = -324
	center_box.offset_right = 576
	center_box.offset_bottom = 324
	_menu_help_overlay.add_child(center_box)

	var box := ColorRect.new()
	box.position = Vector2(116, 70)
	box.size     = Vector2(920, 508)
	box.color    = Color(0.08, 0.10, 0.16, 0.98)
	center_box.add_child(box)

	var top := ColorRect.new()
	top.position = Vector2(116, 70)
	top.size     = Vector2(920, 4)
	top.color    = Color(0.85, 0.65, 0.25, 0.9)
	center_box.add_child(top)

	_menu_help_lbl("DICAS", 0, 82, 1152, 38, 28, Color(1.0, 0.85, 0.30), true)
	_menu_help_lbl("Tudo o que você precisa saber para resgatar o Loopy",
				   0, 120, 1152, 22, 13, Color(0.60, 0.65, 0.78), true)

	# Colunas Rob / Bog
	_menu_help_lbl("ROB   — Ágil", 160, 160, 380, 28, 20, Color(0.40, 0.75, 1.00), true)
	_menu_help_lbl("• Mais rápido e pulo maior\n• [Z] DASH — surto horizontal\n• NÃO empurra caixas",
				   180, 196, 360, 110, 14, Color(0.88, 0.90, 0.98))

	_menu_help_lbl("BOG   — Forte", 612, 160, 380, 28, 20, Color(1.00, 0.60, 0.25), true)
	_menu_help_lbl("• Mais lento, pulo menor\n• [Z] IMPACTO — chão: empurrão  ·  ar: queda\n• Empurra caixas de madeira\n   (basta caminhar contra elas — sem botão)",
				   632, 196, 360, 110, 14, Color(0.88, 0.90, 0.98))

	var sep := ColorRect.new()
	sep.position = Vector2(576, 160)
	sep.size     = Vector2(2, 150)
	sep.color    = Color(0.25, 0.30, 0.45, 0.45)
	_menu_help_overlay.get_node("CenterBox").add_child(sep)

	_menu_help_lbl("CONTROLES", 0, 330, 1152, 24, 16, Color(0.50, 0.88, 0.55), true)
	_menu_help_lbl("A/D ou ←/→  mover   ·   ESPAÇO  pular   ·   TAB  trocar personagem   ·   Z  habilidade   ·   ESC  pausa",
				   0, 358, 1152, 22, 14, Color(0.88, 0.90, 0.98), true)

	_menu_help_lbl("★ ESTRELAS", 0, 400, 1152, 24, 16, Color(1.0, 0.85, 0.30), true)
	_menu_help_lbl("3 estrelas normais + 1 estrela do Bog (alta — empurre a caixa de madeira para usar como degrau)",
				   0, 428, 1152, 22, 13, Color(0.95, 0.85, 0.40), true)

	var btn_close := Button.new()
	btn_close.text     = "Voltar"
	btn_close.position = Vector2(436, 508)
	btn_close.size     = Vector2(280, 42)
	btn_close.add_theme_font_size_override("font_size", 18)
	btn_close.pressed.connect(_close_menu_help)
	_menu_help_overlay.get_node("CenterBox").add_child(btn_close)
	_setup_button_sounds(btn_close)

func _menu_help_lbl(txt: String, x: float, y: float, w: float, h: float, fs: int,
					col: Color, center: bool = false) -> void:
	var l := Label.new()
	l.text     = txt
	l.position = Vector2(x, y)
	l.size     = Vector2(w, h)
	if center:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", col)
	_menu_help_overlay.get_node("CenterBox").add_child(l)

func _close_menu_help() -> void:
	if _menu_help_overlay and is_instance_valid(_menu_help_overlay):
		_menu_help_overlay.queue_free()
	_menu_help_overlay = null

# ============================================================
# OPÇÕES (acessível pelo botão do menu)
# ============================================================

var _options_overlay: Control = null

func _show_options_menu() -> void:
	if _options_overlay and is_instance_valid(_options_overlay):
		return

	_options_overlay = Control.new()
	_options_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_options_overlay)

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
	center_box.add_child(title)

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
		btn.pressed.connect(func():
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(res["w"], res["h"]))
			# Centraliza a janela
			var screen_size = DisplayServer.screen_get_size()
			var window_size = DisplayServer.window_get_size()
			DisplayServer.window_set_position((screen_size - window_size) / 2)
			GameManager.save_game()
		)
		_options_overlay.get_node("CenterBox").add_child(btn)
		_setup_button_sounds(btn)
		y_pos += 50

	var btn_full = Button.new()
	btn_full.text = "Tela Cheia"
	btn_full.position = Vector2(376, y_pos)
	btn_full.size = Vector2(400, 40)
	btn_full.add_theme_font_size_override("font_size", 18)
	btn_full.add_theme_color_override("font_color", Color(0.50, 0.88, 0.55))
	btn_full.pressed.connect(func():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		GameManager.save_game()
	)
	_options_overlay.get_node("CenterBox").add_child(btn_full)
	_setup_button_sounds(btn_full)
	
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
	btn_close.pressed.connect(_close_options_menu)
	_options_overlay.get_node("CenterBox").add_child(btn_close)
	_setup_button_sounds(btn_close)

func _close_options_menu() -> void:
	if _options_overlay and is_instance_valid(_options_overlay):
		_options_overlay.queue_free()
	_options_overlay = null

# ============================================================
# CRÉDITOS
# ============================================================

var _credits_overlay: Control = null

func _show_credits_menu() -> void:
	if _credits_overlay and is_instance_valid(_credits_overlay):
		return

	_credits_overlay = Control.new()
	_credits_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_credits_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.82)
	_credits_overlay.add_child(dim)

	var center_box = Control.new()
	center_box.name = "CenterBox"
	center_box.set_anchors_preset(Control.PRESET_CENTER)
	center_box.offset_left = -576
	center_box.offset_top = -324
	center_box.offset_right = 576
	center_box.offset_bottom = 324
	_credits_overlay.add_child(center_box)

	var box := ColorRect.new()
	box.position = Vector2(226, 70)
	box.size     = Vector2(700, 500)
	box.color    = Color(0.08, 0.10, 0.16, 0.98)
	center_box.add_child(box)

	var top := ColorRect.new()
	top.position = Vector2(226, 70)
	top.size     = Vector2(700, 4)
	top.color    = Color(0.40, 0.75, 1.00, 0.9)
	center_box.add_child(top)

	_credits_lbl("CRÉDITOS", 226, 90, 700, 30, 26, Color(1.0, 0.85, 0.30), true)
	
	_credits_lbl("Desenvolvedores:", 226, 150, 700, 20, 20, Color(0.50, 0.88, 0.55), true)
	_credits_lbl("Alunos de Engenharia de Computação - UNIFEI Campus Itabira", 226, 180, 700, 40, 16, Color(0.60, 0.65, 0.78), true)
	
	var devs = [
		"FREDERICO PIRES DE MORAES GOMES",
		"GUSTAVO FELIPE FERREIRA SOARES",
		"MATHEUS LUCAS TAVARES BUENO",
		"ROBSON DIAS CARVALHO SOARES"
	]
	
	var y = 220
	for dev in devs:
		_credits_lbl("• " + dev, 226, y, 700, 20, 18, Color(0.88, 0.90, 0.98), true)
		y += 30
		
	_credits_lbl("Professor Orientador:", 226, 360, 700, 20, 20, Color(0.50, 0.88, 0.55), true)
	_credits_lbl("WENDELL FIORAVANTE DA SILVA DINIZ", 226, 390, 700, 20, 18, Color(0.88, 0.90, 0.98), true)

	var btn_close := Button.new()
	btn_close.text     = "Voltar"
	btn_close.position = Vector2(376, 480)
	btn_close.size     = Vector2(400, 42)
	btn_close.add_theme_font_size_override("font_size", 18)
	btn_close.pressed.connect(_close_credits_menu)
	center_box.add_child(btn_close)
	_setup_button_sounds(btn_close)

func _credits_lbl(txt: String, x: float, y: float, w: float, h: float, fs: int, col: Color, center: bool = false) -> void:
	var l := Label.new()
	l.text     = txt
	l.position = Vector2(x, y)
	l.size     = Vector2(w, h)
	if center:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", col)
	_credits_overlay.get_node("CenterBox").add_child(l)

func _close_credits_menu() -> void:
	if _credits_overlay and is_instance_valid(_credits_overlay):
		_credits_overlay.queue_free()
	_credits_overlay = null

func _start_game() -> void:
	_newspaper_visible = false
	_intro_visible     = false
	SoundManager.play_sfx("collect") # Som de início
	if GameManager.current_level_index > 0:
		GameManager.continue_game()
	else:
		GameManager.start_game()
	get_tree().change_scene_to_file("res://Scenes/scene1.tscn")

# ============================================================
# INTRO DOS PERSONAGENS (após o jornal, antes do jogo)
# ============================================================

func _build_character_intro() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.039, 0.051, 0.102, 1.0)
	root.add_child(dim)

	var center_box = Control.new()
	center_box.set_anchors_preset(Control.PRESET_CENTER)
	center_box.offset_left = -576
	center_box.offset_top = -324
	center_box.offset_right = 576
	center_box.offset_bottom = 324
	root.add_child(center_box)

	# Título
	_nl(center_box, "CONHEÇA SEUS HERÓIS",
		0, 32, 1152, 50, 34, Color(0.95, 0.95, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	_nl(center_box, "Dois amigos em busca de Loopy  ·  cada um com um jeito",
		0, 78, 1152, 24, 14, Color(0.60, 0.65, 0.80), HORIZONTAL_ALIGNMENT_CENTER)

	# Linha divisória
	var divider := ColorRect.new()
	divider.position = Vector2(576, 130)
	divider.size     = Vector2(2, 400)
	divider.color    = Color(0.251, 0.302, 0.451, 1.0)
	center_box.add_child(divider)

	# ---- ROB (lado esquerdo) ----
	_build_hero_card(center_box, "res://Assets/Characters/Main_2/Idle.png", 7, 50, 112, # Mude o 0 para mover horizontalmente
		70, "ROB", Color(0.30, 0.65, 1.00),
		"Ágil e rápido",
		[
			"•  Corre mais rápido que o Bog",
			"•  Pulo mais alto",
			"•  [Z] DASH — surto horizontal curto",
			"",
			"✗  NÃO empurra caixas",
		])

	# ---- BOG (lado direito) ----
	_build_hero_card(center_box, "res://Assets/Characters/Main_1/Idle.png", 6, 50, 112, # Mude o 0 para mover horizontalmente
		640, "BOG", Color(1.00, 0.60, 0.25),
		"Forte e pesado",
		[
			"•  Mais lento, pulo menor",
			"•  [Z] IMPACTO — chão: empurrão forte",
			"             ar: queda com força",
			"•  Empurra caixas de madeira",
			"   (basta caminhar contra elas)",
		])

	# ---- Rodapé: controles gerais ----
	var footer_bg := ColorRect.new()
	footer_bg.position = Vector2(76, 540)
	footer_bg.size     = Vector2(1000, 60)
	footer_bg.color    = Color(0.102, 0.078, 0.039, 1.0)
	center_box.add_child(footer_bg)

	_nl(center_box, "CONTROLES  ·  A/D ou Setas = Mover   ·   ESPAÇO = Pular   ·   TAB = Trocar personagem   ·   Z = Habilidade   ·   ESC = Pausa",
		76, 552, 1000, 18, 13, Color(0.85, 0.78, 0.40), HORIZONTAL_ALIGNMENT_CENTER)
	_nl(center_box, "Colete ★ estrelas pelo caminho — algumas só se alcançam com o bloco do Bog como degrau",
		76, 574, 1000, 18, 11, Color(1.0, 0.85, 0.35), HORIZONTAL_ALIGNMENT_CENTER)

	_nl(center_box, "—  PRESSIONE  ESPAÇO  PARA COMEÇAR  —",
		0, 612, 1152, 30, 18,
		Color(0.30, 1.0, 0.45), HORIZONTAL_ALIGNMENT_CENTER)

	root.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(root, "modulate:a", 1.0, 0.55)

	_intro_visible = true

func _build_hero_card(parent: Node, sprite_path: String, h_frames: int, crop_top: float, offset_x: float,
					  x: float, hero_name: String, color: Color,
					  subtitle: String, bullets: Array) -> void:
	# Retrato (sprite do jogo)
	var tex: Texture2D = load(sprite_path)
	if tex != null:
		var sprite := Sprite2D.new()
		sprite.texture  = tex
		if crop_top > 0:
			sprite.region_enabled = true
			sprite.region_rect = Rect2(0, crop_top, tex.get_width(), tex.get_height() - crop_top)
		sprite.hframes  = h_frames
		sprite.frame    = 0
		sprite.scale    = Vector2(1.9, 1.9)
		var frame_h := tex.get_height() - crop_top
		sprite.position = Vector2(x + 120 + offset_x, 170 + frame_h * 0.95)
		parent.add_child(sprite)

	# Moldura do retrato
	var frame_bg := ColorRect.new()
	frame_bg.position = Vector2(x + 20 + offset_x, 140)
	frame_bg.size     = Vector2(200, 200)
	frame_bg.color    = Color(color.r * 0.20, color.g * 0.20, color.b * 0.22, 0.50)
	parent.add_child(frame_bg)
	parent.move_child(frame_bg, parent.get_child_count() - 2)  # atrás do sprite

	# Nome grande
	_nl(parent, hero_name, x, 130, 470, 52, 44, color, HORIZONTAL_ALIGNMENT_CENTER)

	# Subtítulo
	_nl(parent, subtitle, x, 350, 470, 24, 16,
		Color(color.r * 0.85, color.g * 0.85, color.b * 0.90),
		HORIZONTAL_ALIGNMENT_CENTER)

	# Bullets de habilidades
	var y_start: float = 384
	for i in range(bullets.size()):
		_nl(parent, bullets[i], x + 40, y_start + i * 24, 430, 22, 14,
			Color(0.88, 0.90, 0.95))

# ============================================================
# JORNAL (CUTSCENE PRE-JOGO)
# ============================================================

func _nl(parent: Node, txt: String, px: float, py: float, pw: float, ph: float,
		 fs: int, col: Color, ha: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text     = txt
	l.position = Vector2(px, py)
	l.size     = Vector2(pw, ph)
	
	var base_font: Font = newspaper_font
	if base_font == null:
		var sys_font = SystemFont.new()
		sys_font.font_names = PackedStringArray(["Times New Roman", "Georgia", "Serif"])
		base_font = sys_font
		
	var var_font = FontVariation.new()
	var_font.base_font = base_font
	var_font.spacing_glyph = newspaper_letter_spacing
	
	l.add_theme_font_override("font", var_font)
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", col)
	l.add_theme_constant_override("line_spacing", newspaper_line_spacing)
	l.horizontal_alignment = ha
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(l)
	return l

func _build_newspaper() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	# Fundo escuro
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.80)
	root.add_child(dim)

	var center_box = Control.new()
	center_box.set_anchors_preset(Control.PRESET_CENTER)
	center_box.offset_left = -576
	center_box.offset_top = -324
	center_box.offset_right = 576
	center_box.offset_bottom = 324
	root.add_child(center_box)

	# --- Papel do jornal ---
	const PX: float = 76.0
	const PY: float = 22.0
	const PW: float = 1000.0
	const PH: float = 606.0

	var paper_container = Control.new()
	# Estilização: rotação leve para dar ar dinâmico
	paper_container.rotation_degrees = -1.5
	paper_container.position = Vector2(20, 20) # Ajuste de offset
	center_box.add_child(paper_container)

	# Sombra do jornal (múltiplas camadas para profundidade)
	for i in range(5):
		var shadow_layer := Panel.new()
		var shadow_style := StyleBoxFlat.new()
		shadow_style.bg_color = Color(0, 0, 0, 0.18 - i * 0.03)
		shadow_style.corner_radius_bottom_left = 16
		shadow_style.corner_radius_bottom_right = 16
		shadow_layer.add_theme_stylebox_override("panel", shadow_style)
		shadow_layer.position = Vector2(PX + 10 + i * 6, PY + 10 + i * 6)
		shadow_layer.size     = Vector2(PW, PH)
		paper_container.add_child(shadow_layer)

	var paper := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.965, 0.930, 0.810)
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	paper.add_theme_stylebox_override("panel", style)
	paper.position = Vector2(PX, PY)
	paper.size     = Vector2(PW, PH)
	paper_container.add_child(paper)

	# Bordas laterais escuras (efeito envelhecido)
	for xv in [PX, PX + PW - 6]:
		var edge := ColorRect.new()
		edge.position = Vector2(xv, PY)
		edge.size     = Vector2(6, PH)
		edge.color    = Color(0.80, 0.74, 0.60, 0.4)
		paper_container.add_child(edge)

	# ---- Cabeçalho ----
	var header := ColorRect.new()
	header.position = Vector2(PX, PY)
	header.size     = Vector2(PW, 70)
	header.color    = Color(0.07, 0.05, 0.03)
	paper_container.add_child(header)

	_nl(paper_container, newspaper_title,
		PX, PY + 6, PW, 40, 36, Color(0.98, 0.96, 0.88), HORIZONTAL_ALIGNMENT_CENTER)
	_nl(paper_container, newspaper_subtitle,
		PX, PY + 48, PW, 18, 11, Color(0.68, 0.64, 0.52), HORIZONTAL_ALIGNMENT_CENTER)

	# Fio separador superior
	var sep1 := ColorRect.new()
	sep1.position = Vector2(PX, PY + 70)
	sep1.size     = Vector2(PW, 3)
	sep1.color    = Color(0.14, 0.11, 0.07)
	paper_container.add_child(sep1)

	# ---- Manchete ----
	_nl(paper_container, newspaper_headline,
		PX + 10, PY + 78, PW - 20, 50, 31,
		Color(0.06, 0.05, 0.04), HORIZONTAL_ALIGNMENT_CENTER)

	_nl(paper_container, newspaper_subheadline,
		PX + 60, PY + 130, PW - 120, 22, 13,
		Color(0.22, 0.18, 0.12), HORIZONTAL_ALIGNMENT_CENTER)

	# Fio separador sub-manchete
	var sep2 := ColorRect.new()
	sep2.position = Vector2(PX + 20, PY + 158)
	sep2.size     = Vector2(PW - 40, 2)
	sep2.color    = Color(0.22, 0.16, 0.08)
	paper_container.add_child(sep2)

	# ---- Coluna esquerda: artigo ----
	_nl(paper_container, newspaper_author,
		PX + 20, PY + 164, 590, 16, 10, Color(0.38, 0.32, 0.22), HORIZONTAL_ALIGNMENT_CENTER)

	var ay: float = PY + 182.0
	for p in newspaper_paragraphs:
		_nl(paper_container, p, PX + 20, ay, 600, 78, 14, Color(0.10, 0.09, 0.07), HORIZONTAL_ALIGNMENT_CENTER)
		ay += 80.0

	# Fio separador vertical entre colunas
	var vsep := ColorRect.new()
	vsep.position = Vector2(PX + 642, PY + 158)
	vsep.size     = Vector2(2, 398)
	vsep.color    = Color(0.28, 0.22, 0.12, 0.45)
	paper_container.add_child(vsep)

	# ---- Coluna direita: foto + box ----
	# Moldura externa (efeito de foto antiga em sépia)
	var photo_frame := ColorRect.new()
	photo_frame.position = Vector2(PX + 650, PY + 156)
	photo_frame.size     = Vector2(332, 222)
	photo_frame.color    = Color(0.18, 0.14, 0.08)
	paper_container.add_child(photo_frame)

	var photo := ColorRect.new()
	photo.position = Vector2(PX + 656, PY + 162)
	photo.size     = Vector2(320, 210)
	photo.color    = Color(0.82, 0.72, 0.52)  # fundo sépia claro
	paper_container.add_child(photo)

	# Chão da foto (tom mais escuro)
	var photo_ground := ColorRect.new()
	photo_ground.position = Vector2(PX + 656, PY + 340)
	photo_ground.size     = Vector2(320, 32)
	photo_ground.color    = Color(0.60, 0.48, 0.32)
	paper_container.add_child(photo_ground)

	# Loopy detalhado (tons sépia para parecer foto de jornal)
	_draw_loopy(paper_container, PX + 816, PY + 355, 1.3, true)

	# Cantos da moldura (decoração de foto antiga)
	for cx in [PX + 652, PX + 970]:
		for cy in [PY + 158, PY + 368]:
			var corner := ColorRect.new()
			corner.position = Vector2(cx, cy)
			corner.size     = Vector2(10, 10)
			corner.color    = Color(0.10, 0.08, 0.05)
			paper_container.add_child(corner)

	_nl(paper_container, newspaper_photo_caption,
		PX + 656, PY + 384, 320, 18, 10,
		Color(0.28, 0.22, 0.14), HORIZONTAL_ALIGNMENT_CENTER)

	# Box de destaque
	var hl := ColorRect.new()
	hl.position = Vector2(PX + 656, PY + 412)
	hl.size     = Vector2(320, 126)
	hl.color    = Color(0.935, 0.875, 0.635)
	paper_container.add_child(hl)

	var hl_top := ColorRect.new()
	hl_top.position = Vector2(PX + 656, PY + 412)
	hl_top.size     = Vector2(320, 3)
	hl_top.color    = Color(0.16, 0.11, 0.05)
	paper_container.add_child(hl_top)

	_nl(paper_container, newspaper_box_title,
		PX + 656, PY + 418, 320, 20, 12,
		Color(0.07, 0.06, 0.04), HORIZONTAL_ALIGNMENT_CENTER)

	_nl(paper_container, newspaper_box_text,
		PX + 666, PY + 440, 300, 96, 13, Color(0.14, 0.11, 0.07), HORIZONTAL_ALIGNMENT_CENTER)

	# ---- Rodapé ----
	var sep_foot := ColorRect.new()
	sep_foot.position = Vector2(PX, PY + PH - 50)
	sep_foot.size     = Vector2(PW, 3)
	sep_foot.color    = Color(0.14, 0.11, 0.07)
	paper_container.add_child(sep_foot)

	_nl(paper_container, "—  PRESSIONE  ESPAÇO  PARA COMEÇAR A BUSCA  —",
		PX, PY + PH - 42, PW, 38, 16,
		Color(0.07, 0.05, 0.04), HORIZONTAL_ALIGNMENT_CENTER)

	# Animação fade-in e scale para dar profundidade
	root.modulate.a = 0.0
	paper_container.pivot_offset = Vector2(PX + PW / 2.0, PY + PH / 2.0)
	paper_container.scale = Vector2(0.92, 0.92)
	
	var tween := create_tween().set_parallel(true)
	tween.tween_property(root, "modulate:a", 1.0, 0.55)
	tween.tween_property(paper_container, "scale", Vector2(1.0, 1.0), 0.65).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	_newspaper_visible = true

# ============================================================
# DESENHO DO LOOPY (procedural, usado no jornal e na cena final)
# ============================================================

func _rect(parent: Node, x: float, y: float, w: float, h: float, col: Color) -> void:
	var r := ColorRect.new()
	r.position = Vector2(x, y)
	r.size     = Vector2(w, h)
	r.color    = col
	parent.add_child(r)

## Desenha o Loopy com base em (cx, cy) = posição dos pés (centro).
## Cada _r(dx, dy, w, h, col) desenha um retângulo onde dy = distância do TOPO
## do retângulo acima dos pés. Ou seja, dy maior = mais alto na tela.
func _draw_loopy(parent: Node, cx: float, cy: float, s: float, sepia: bool) -> void:
	var skin   := _sp(Color(0.96, 0.82, 0.66), sepia)
	var hair   := _sp(Color(0.42, 0.26, 0.14), sepia)
	var beard  := _sp(Color(0.52, 0.36, 0.20), sepia)
	var beanie := _sp(Color(0.30, 0.55, 0.28), sepia)
	var leaf   := _sp(Color(0.55, 0.78, 0.30), sepia)
	var hood   := _sp(Color(0.95, 0.74, 0.22), sepia)
	var cape   := _sp(Color(0.44, 0.24, 0.52), sepia)
	var jeans  := _sp(Color(0.30, 0.40, 0.62), sepia)
	var shoe   := _sp(Color(0.36, 0.60, 0.32), sepia)
	var staff  := _sp(Color(0.34, 0.20, 0.10), sepia)
	var cup    := _sp(Color(0.96, 0.94, 0.88), sepia)
	var tea    := _sp(Color(0.50, 0.30, 0.16), sepia)
	var duck   := _sp(Color(1.00, 0.82, 0.18), sepia)
	var beak   := _sp(Color(0.96, 0.56, 0.14), sepia)
	var steam  := _sp(Color(0.85, 0.85, 0.80), sepia); steam.a = 0.7
	var dark   := _sp(Color(0.10, 0.08, 0.06), sepia)

	# Capa roxa atrás (largura cheia, atrás do corpo)
	_prect(parent, cx, cy, s, -30,  95, 60, 75, cape)

	# Pés: tênis verdes + sola escura
	_prect(parent, cx, cy, s, -14,  9, 12, 9, shoe)
	_prect(parent, cx, cy, s,   2,  9, 12, 9, shoe)
	_prect(parent, cx, cy, s, -14,  2, 12, 2, dark)
	_prect(parent, cx, cy, s,   2,  2, 12, 2, dark)

	# Jeans
	_prect(parent, cx, cy, s, -12, 38, 10, 29, jeans)
	_prect(parent, cx, cy, s,   2, 38, 10, 29, jeans)
	# Rasgo no jeans
	_prect(parent, cx, cy, s,  -9, 22,  7, 2,
			Color(jeans.r + 0.10, jeans.g + 0.08, jeans.b + 0.06))

	# Moletom amarelo (corpo)
	_prect(parent, cx, cy, s, -18, 72, 36, 34, hood)
	# Sombra inferior do moletom
	_prect(parent, cx, cy, s, -18, 40, 36, 3,
			Color(hood.r * 0.7, hood.g * 0.6, hood.b * 0.4))

	# Braço esquerdo segurando patinho
	_prect(parent, cx, cy, s, -24, 65, 7, 22, hood)
	# Patinho de borracha
	_prect(parent, cx, cy, s, -36, 55, 12, 8, duck)
	_prect(parent, cx, cy, s, -30, 62,  8, 7, duck)   # cabeça pato
	_prect(parent, cx, cy, s, -38, 60,  3, 2, dark)    # olhinho
	_prect(parent, cx, cy, s, -42, 58,  4, 3, beak)    # bico

	# Braço direito (segurando cajado)
	_prect(parent, cx, cy, s,  17, 65, 7, 22, hood)

	# Capa à frente (lado direito, abaixo do braço)
	_prect(parent, cx, cy, s,  16, 55, 10, 45, cape)

	# Cabeça (pele)
	_prect(parent, cx, cy, s, -12, 100, 24, 26, skin)

	# Barba (cobre metade inferior do rosto)
	_prect(parent, cx, cy, s, -12, 84, 24, 13, beard)
	_prect(parent, cx, cy, s, -10, 75, 20,  5, beard)

	# Cabelo lateral (sob gorro)
	_prect(parent, cx, cy, s, -14, 98, 4, 12, hair)
	_prect(parent, cx, cy, s,  10, 98, 4, 12, hair)

	# Olhos
	_prect(parent, cx, cy, s, -7, 93, 3, 3, dark)
	_prect(parent, cx, cy, s,  3, 93, 3, 3, dark)

	# Nariz
	_prect(parent, cx, cy, s, -2, 88, 4, 4,
			Color(skin.r * 0.85, skin.g * 0.72, skin.b * 0.60))

	# Boca (linha na barba)
	_prect(parent, cx, cy, s, -4, 82, 8, 1.5, dark)

	# Gorro verde
	_prect(parent, cx, cy, s, -15, 118, 30, 14, beanie)
	_prect(parent, cx, cy, s, -14, 106, 28, 3,
			Color(beanie.r * 0.65, beanie.g * 0.65, beanie.b * 0.60))

	# Folha no gorro
	_prect(parent, cx, cy, s,  2, 125, 7, 6, leaf)
	_prect(parent, cx, cy, s,  6, 130, 4, 4, leaf)

	# Cajado (atrás, vertical — do braço direito até a xícara)
	_prect(parent, cx, cy, s, 22, 122, 4, 70, staff)

	# Xícara no topo do cajado
	_prect(parent, cx, cy, s, 18, 134, 14, 11, cup)
	_prect(parent, cx, cy, s, 20, 132,  9,  4, tea)
	_prect(parent, cx, cy, s, 32, 130,  3,  6, cup)  # alça

	# Vapor da xícara
	_prect(parent, cx, cy, s, 22, 140, 2, 4, steam)
	_prect(parent, cx, cy, s, 26, 145, 2, 5, steam)
	_prect(parent, cx, cy, s, 20, 150, 2, 4, steam)

## Converte cor para tom sépia, mantendo alfa.
func _sp(c: Color, sepia: bool) -> Color:
	if not sepia:
		return c
	var g: float = c.r * 0.3 + c.g * 0.59 + c.b * 0.11
	return Color(clamp(g * 0.95 + 0.12, 0.0, 1.0),
				 clamp(g * 0.78 + 0.06, 0.0, 1.0),
				 clamp(g * 0.55,        0.0, 1.0),
				 c.a)

## Retângulo relativo: dx horizontal em torno de cx, dy = topo acima dos pés cy.
func _prect(parent: Node, cx: float, cy: float, s: float,
			dx: float, dy: float, w: float, h: float, col: Color) -> void:
	_rect(parent, cx + dx * s, cy - dy * s, w * s, h * s, col)

## Desenha o Rob (silhueta simples colorida) nos pés (cx, cy).
func _draw_rob(parent: Node, cx: float, cy: float, s: float) -> void:
	var skin := Color(0.98, 0.84, 0.70)
	var shirt := Color(0.30, 0.65, 1.00)
	var pants := Color(0.22, 0.28, 0.42)
	var shoe  := Color(0.14, 0.14, 0.18)
	var hair  := Color(0.22, 0.16, 0.10)
	_rect(parent, cx - 10 * s, cy - 6 * s,  8 * s, 6 * s, shoe)
	_rect(parent, cx + 2  * s, cy - 6 * s,  8 * s, 6 * s, shoe)
	_rect(parent, cx - 9  * s, cy - 24 * s, 7 * s, 18 * s, pants)
	_rect(parent, cx + 2  * s, cy - 24 * s, 7 * s, 18 * s, pants)
	_rect(parent, cx - 12 * s, cy - 48 * s, 24 * s, 24 * s, shirt)
	_rect(parent, cx - 16 * s, cy - 42 * s, 4  * s, 18 * s, skin)  # braço
	_rect(parent, cx + 12 * s, cy - 42 * s, 4  * s, 18 * s, skin)
	_rect(parent, cx - 8  * s, cy - 62 * s, 16 * s, 14 * s, skin)  # cabeça
	_rect(parent, cx - 9  * s, cy - 66 * s, 18 * s, 6  * s, hair)
	_rect(parent, cx - 4  * s, cy - 56 * s, 2  * s, 2  * s, Color.BLACK)
	_rect(parent, cx + 2  * s, cy - 56 * s, 2  * s, 2  * s, Color.BLACK)
	_rect(parent, cx - 2  * s, cy - 50 * s, 4  * s, 1.2 * s, Color(0.6, 0.2, 0.2))  # sorriso

## Desenha o Bog (silhueta simples colorida) nos pés (cx, cy).
func _draw_bog(parent: Node, cx: float, cy: float, s: float) -> void:
	var skin := Color(0.98, 0.78, 0.62)
	var shirt := Color(1.00, 0.55, 0.20)
	var pants := Color(0.36, 0.24, 0.14)
	var shoe  := Color(0.18, 0.14, 0.10)
	var hair  := Color(0.10, 0.08, 0.06)
	# Bog é maior/pesado
	_rect(parent, cx - 12 * s, cy - 6 * s,  10 * s, 6 * s, shoe)
	_rect(parent, cx + 2  * s, cy - 6 * s,  10 * s, 6 * s, shoe)
	_rect(parent, cx - 11 * s, cy - 26 * s, 9 * s, 20 * s, pants)
	_rect(parent, cx + 2  * s, cy - 26 * s, 9 * s, 20 * s, pants)
	_rect(parent, cx - 16 * s, cy - 54 * s, 32 * s, 28 * s, shirt)
	_rect(parent, cx - 20 * s, cy - 48 * s, 4  * s, 20 * s, skin)
	_rect(parent, cx + 16 * s, cy - 48 * s, 4  * s, 20 * s, skin)
	_rect(parent, cx - 10 * s, cy - 70 * s, 20 * s, 16 * s, skin)
	_rect(parent, cx - 11 * s, cy - 74 * s, 22 * s, 6  * s, hair)
	_rect(parent, cx - 5  * s, cy - 62 * s, 2  * s, 2  * s, Color.BLACK)
	_rect(parent, cx + 3  * s, cy - 62 * s, 2  * s, 2  * s, Color.BLACK)
	_rect(parent, cx - 2  * s, cy - 56 * s, 4  * s, 1.2 * s, Color(0.5, 0.2, 0.2))

func _setup_button_sounds(btn: Button) -> void:
	btn.pressed.connect(func(): SoundManager.play_sfx("collect"))
	btn.mouse_entered.connect(func(): SoundManager.play_sfx("switch"))
