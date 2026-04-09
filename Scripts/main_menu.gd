extends Control

## Main Menu - Tela de titulo do Lost & Loopy
## Exibe jornal narrativo antes de iniciar o jogo.

var title_label: Label
var start_button: Button
var quit_button: Button
var bg: ColorRect
var time: float = 0.0
var _newspaper_visible: bool = false

func _ready() -> void:
	_build_ui()

func _process(delta: float) -> void:
	time += delta
	if title_label:
		title_label.rotation = sin(time * 1.5) * 0.03
		title_label.position.y = 100 + sin(time * 2.0) * 5.0
	if _newspaper_visible:
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
			_start_game()

# ============================================================
# CONSTRUCAO DO MENU
# ============================================================

func _build_ui() -> void:
	bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.08, 0.10, 0.18)
	add_child(bg)

	for i in range(30):
		var star := ColorRect.new()
		star.size     = Vector2(2, 2)
		star.position = Vector2(randf() * 1152, randf() * 648)
		star.color    = Color(1, 1, 1, randf() * 0.5 + 0.1)
		add_child(star)

	title_label = Label.new()
	title_label.text     = "Lost & Loopy"
	title_label.position = Vector2(280, 100)
	title_label.size     = Vector2(600, 80)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 64)
	title_label.add_theme_color_override("font_color", Color(0.3, 0.85, 0.45))
	title_label.pivot_offset = Vector2(300, 40)
	add_child(title_label)

	var subtitle := Label.new()
	subtitle.text     = "Encontre seu amigo perdido!"
	subtitle.position = Vector2(300, 200)
	subtitle.size     = Vector2(560, 40)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 22)
	subtitle.add_theme_color_override("font_color", Color(0.65, 0.65, 0.75))
	add_child(subtitle)

	var concept := Label.new()
	concept.text     = "\"Um jogo onde você nunca controla da mesma forma duas vezes.\""
	concept.position = Vector2(220, 240)
	concept.size     = Vector2(720, 30)
	concept.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	concept.add_theme_font_size_override("font_size", 15)
	concept.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3, 0.7))
	add_child(concept)

	var btn_box := VBoxContainer.new()
	btn_box.position = Vector2(426, 320)
	btn_box.size     = Vector2(300, 200)
	btn_box.add_theme_constant_override("separation", 15)
	add_child(btn_box)

	start_button = Button.new()
	start_button.text = "Jogar"
	start_button.custom_minimum_size = Vector2(300, 55)
	start_button.add_theme_font_size_override("font_size", 26)
	start_button.pressed.connect(_on_start)
	btn_box.add_child(start_button)

	quit_button = Button.new()
	quit_button.text = "Sair"
	quit_button.custom_minimum_size = Vector2(300, 45)
	quit_button.add_theme_font_size_override("font_size", 20)
	quit_button.pressed.connect(_on_quit)
	btn_box.add_child(quit_button)

	var controls := Label.new()
	controls.text     = "Controles:\nA/D ou Setas = Mover  |  Espaço = Pular  |  TAB = Trocar  |  Z = Habilidade"
	controls.position = Vector2(200, 520)
	controls.size     = Vector2(760, 60)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 15)
	controls.add_theme_color_override("font_color", Color(0.5, 0.5, 0.58))
	add_child(controls)

	var credits := Label.new()
	credits.text     = "Lost & Loopy - Projeto Jogos Digitais 2026"
	credits.position = Vector2(350, 610)
	credits.size     = Vector2(460, 30)
	credits.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits.add_theme_font_size_override("font_size", 12)
	credits.add_theme_color_override("font_color", Color(0.35, 0.35, 0.4))
	add_child(credits)

# ============================================================
# ACOES
# ============================================================

func _on_start() -> void:
	start_button.disabled = true
	quit_button.disabled  = true
	_build_newspaper()

func _on_quit() -> void:
	get_tree().quit()

func _start_game() -> void:
	_newspaper_visible = false
	GameManager.start_game()
	get_tree().change_scene_to_file("res://Scenes/scene1.tscn")

# ============================================================
# JORNAL (CUTSCENE PRE-JOGO)
# ============================================================

func _nl(parent: Node, txt: String, px: float, py: float, pw: float, ph: float,
		 fs: int, col: Color, ha: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text     = txt
	l.position = Vector2(px, py)
	l.size     = Vector2(pw, ph)
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", col)
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

	# --- Papel do jornal ---
	const PX: float = 76.0
	const PY: float = 22.0
	const PW: float = 1000.0
	const PH: float = 606.0

	var paper := ColorRect.new()
	paper.position = Vector2(PX, PY)
	paper.size     = Vector2(PW, PH)
	paper.color    = Color(0.965, 0.930, 0.810)
	root.add_child(paper)

	# Bordas laterais escuras (efeito envelhecido)
	for xv in [PX, PX + PW - 6]:
		var edge := ColorRect.new()
		edge.position = Vector2(xv, PY)
		edge.size     = Vector2(6, PH)
		edge.color    = Color(0.80, 0.74, 0.60, 0.4)
		root.add_child(edge)

	# ---- Cabeçalho ----
	var header := ColorRect.new()
	header.position = Vector2(PX, PY)
	header.size     = Vector2(PW, 70)
	header.color    = Color(0.07, 0.05, 0.03)
	root.add_child(header)

	_nl(root, "O DIÁRIO DA CIDADE",
		PX, PY + 6, PW, 40, 36, Color(0.98, 0.96, 0.88), HORIZONTAL_ALIGNMENT_CENTER)
	_nl(root, "Edição Especial  ·  Cidade Urbana, 2026  ·  Número 4.521",
		PX, PY + 48, PW, 18, 11, Color(0.68, 0.64, 0.52), HORIZONTAL_ALIGNMENT_CENTER)

	# Fio separador superior
	var sep1 := ColorRect.new()
	sep1.position = Vector2(PX, PY + 70)
	sep1.size     = Vector2(PW, 3)
	sep1.color    = Color(0.14, 0.11, 0.07)
	root.add_child(sep1)

	# ---- Manchete ----
	_nl(root, "GAROTO DESAPARECE APÓS TOMAR CHÁ MISTERIOSO",
		PX + 10, PY + 78, PW - 20, 50, 31,
		Color(0.06, 0.05, 0.04), HORIZONTAL_ALIGNMENT_CENTER)

	_nl(root, "Jovem saiu do Café Loop completamente desorientado após receber chá de senhora misteriosa",
		PX + 60, PY + 130, PW - 120, 22, 13,
		Color(0.22, 0.18, 0.12), HORIZONTAL_ALIGNMENT_CENTER)

	# Fio separador sub-manchete
	var sep2 := ColorRect.new()
	sep2.position = Vector2(PX + 20, PY + 158)
	sep2.size     = Vector2(PW - 40, 2)
	sep2.color    = Color(0.22, 0.16, 0.08)
	root.add_child(sep2)

	# ---- Coluna esquerda: artigo ----
	_nl(root, "Por nosso correspondente especial  ·  Ontem, às 09h47",
		PX + 20, PY + 164, 590, 16, 10, Color(0.38, 0.32, 0.22))

	var paras: Array = [
		"Moradores da região ficaram surpresos ao ver o\njovem Loopy sair do tradicional Café Loop visivelmente\nconfuso, com olhar distante e passos completamente\nerrantes pelas ruas do bairro.",
		"Segundo testemunhas, uma senhora de aparência\nincomum havia lhe servido um chá de ervas de origem\ndesconhecida, dizendo que era \"para clarear a mente\".\nNinguém sabe quem era a misteriosa mulher.",
		"Loopy, normalmente bem-humorado e comunicativo,\ncaminhou pelas ruas sem destino aparente, ignorando\ncompletamente aqueles ao seu redor.\n\"Parecia estar em outro mundo\", disse uma moradora.",
		"Seus amigos inseparáveis Rob e Bog, ao ficarem\nsabendo do ocorrido, partiram imediatamente em\nbusca do amigo perdido pelos bairros da cidade.",
	]
	var ay: float = PY + 182.0
	for p in paras:
		_nl(root, p, PX + 20, ay, 600, 72, 13, Color(0.10, 0.09, 0.07))
		ay += 76.0

	# Fio separador vertical entre colunas
	var vsep := ColorRect.new()
	vsep.position = Vector2(PX + 642, PY + 158)
	vsep.size     = Vector2(2, 398)
	vsep.color    = Color(0.28, 0.22, 0.12, 0.45)
	root.add_child(vsep)

	# ---- Coluna direita: foto + box ----
	# "Foto" do Loopy (placeholder artístico)
	var photo := ColorRect.new()
	photo.position = Vector2(PX + 656, PY + 162)
	photo.size     = Vector2(320, 210)
	photo.color    = Color(0.26, 0.24, 0.18)
	root.add_child(photo)

	# Silhueta do Loopy
	var sh_body := ColorRect.new()
	sh_body.position = Vector2(PX + 780, PY + 218)
	sh_body.size     = Vector2(48, 88)
	sh_body.color    = Color(0.11, 0.09, 0.07)
	root.add_child(sh_body)

	var sh_head := ColorRect.new()
	sh_head.position = Vector2(PX + 785, PY + 183)
	sh_head.size     = Vector2(38, 38)
	sh_head.color    = Color(0.11, 0.09, 0.07)
	root.add_child(sh_head)

	var q_mark := Label.new()
	q_mark.text     = "?"
	q_mark.position = Vector2(PX + 828, PY + 183)
	q_mark.add_theme_font_size_override("font_size", 46)
	q_mark.add_theme_color_override("font_color", Color(0.88, 0.80, 0.44, 0.50))
	root.add_child(q_mark)

	_nl(root, "Loopy, visto pela última vez saindo do Café Loop",
		PX + 656, PY + 374, 320, 18, 10,
		Color(0.28, 0.22, 0.14), HORIZONTAL_ALIGNMENT_CENTER)

	# Box de destaque
	var hl := ColorRect.new()
	hl.position = Vector2(PX + 656, PY + 396)
	hl.size     = Vector2(320, 126)
	hl.color    = Color(0.935, 0.875, 0.635)
	root.add_child(hl)

	var hl_top := ColorRect.new()
	hl_top.position = Vector2(PX + 656, PY + 396)
	hl_top.size     = Vector2(320, 3)
	hl_top.color    = Color(0.16, 0.11, 0.05)
	root.add_child(hl_top)

	_nl(root, "QUEM É LOOPY?",
		PX + 656, PY + 402, 320, 20, 12,
		Color(0.07, 0.06, 0.04), HORIZONTAL_ALIGNMENT_CENTER)

	_nl(root, "Jovem de personalidade descontraída,\nconhecido pelo bom humor e pelo hábito\nde ler o jornal e tomar chá todas as manhãs\nno banco da praça em frente ao Café Loop.",
		PX + 666, PY + 424, 300, 96, 12, Color(0.14, 0.11, 0.07))

	# ---- Rodapé ----
	var sep_foot := ColorRect.new()
	sep_foot.position = Vector2(PX, PY + PH - 50)
	sep_foot.size     = Vector2(PW, 3)
	sep_foot.color    = Color(0.14, 0.11, 0.07)
	root.add_child(sep_foot)

	_nl(root, "—  PRESSIONE  ESPAÇO  PARA COMEÇAR A BUSCA  —",
		PX, PY + PH - 42, PW, 38, 16,
		Color(0.07, 0.05, 0.04), HORIZONTAL_ALIGNMENT_CENTER)

	# Animação fade-in
	root.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(root, "modulate:a", 1.0, 0.55)

	_newspaper_visible = true
