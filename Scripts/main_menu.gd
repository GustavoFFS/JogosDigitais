extends Control

## Main Menu - Tela de titulo do Lost & Loopy
## Exibe jornal narrativo antes de iniciar o jogo.

var title_label: Label
var start_button: Button
var quit_button: Button
var bg: ColorRect
var time: float = 0.0
var _newspaper_visible: bool = false
var _intro_visible: bool = false

func _ready() -> void:
	_build_ui()

func _process(delta: float) -> void:
	time += delta
	if title_label:
		title_label.rotation = sin(time * 1.5) * 0.03
		title_label.position.y = 100 + sin(time * 2.0) * 5.0
	if _newspaper_visible:
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
			_newspaper_visible = false
			_build_character_intro()
	elif _intro_visible:
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
	_intro_visible     = false
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
	dim.color = Color(0.04, 0.05, 0.10, 0.97)
	root.add_child(dim)

	# Título
	_nl(root, "CONHEÇA SEUS HERÓIS",
		0, 32, 1152, 50, 34, Color(0.95, 0.95, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	_nl(root, "Dois amigos em busca de Loopy  ·  cada um com um jeito",
		0, 78, 1152, 24, 14, Color(0.60, 0.65, 0.80), HORIZONTAL_ALIGNMENT_CENTER)

	# Linha divisória
	var divider := ColorRect.new()
	divider.position = Vector2(576, 130)
	divider.size     = Vector2(2, 400)
	divider.color    = Color(0.25, 0.30, 0.45, 0.45)
	root.add_child(divider)

	# ---- ROB (lado esquerdo) ----
	_build_hero_card(root, "res://Assets/Characters/Main_2/Idle.png",
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
	_build_hero_card(root, "res://Assets/Characters/Main_1/Idle.png",
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
	footer_bg.color    = Color(0.10, 0.08, 0.04, 0.85)
	root.add_child(footer_bg)

	_nl(root, "CONTROLES  ·  A/D ou Setas = Mover   ·   ESPAÇO = Pular   ·   TAB = Trocar personagem   ·   Z = Habilidade   ·   ESC = Pausa",
		76, 552, 1000, 18, 13, Color(0.85, 0.78, 0.40), HORIZONTAL_ALIGNMENT_CENTER)
	_nl(root, "Colete ★ estrelas pelo caminho — algumas só se alcançam com o bloco do Bog como degrau",
		76, 574, 1000, 18, 11, Color(1.0, 0.85, 0.35), HORIZONTAL_ALIGNMENT_CENTER)

	_nl(root, "—  PRESSIONE  ESPAÇO  PARA COMEÇAR  —",
		0, 612, 1152, 30, 18,
		Color(0.30, 1.0, 0.45), HORIZONTAL_ALIGNMENT_CENTER)

	root.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(root, "modulate:a", 1.0, 0.55)

	_intro_visible = true

func _build_hero_card(parent: Node, sprite_path: String,
					  x: float, hero_name: String, color: Color,
					  subtitle: String, bullets: Array) -> void:
	# Retrato (sprite do jogo)
	var tex: Texture2D = load(sprite_path)
	if tex != null:
		var sprite := Sprite2D.new()
		sprite.texture  = tex
		sprite.hframes  = 16
		sprite.frame    = 0
		sprite.scale    = Vector2(1.9, 1.9)
		var frame_h := tex.get_height()
		sprite.position = Vector2(x + 120, 170 + frame_h * 0.95)
		parent.add_child(sprite)

	# Moldura do retrato
	var frame_bg := ColorRect.new()
	frame_bg.position = Vector2(x + 20, 140)
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
	for i in bullets.size():
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
	# Moldura externa (efeito de foto antiga em sépia)
	var photo_frame := ColorRect.new()
	photo_frame.position = Vector2(PX + 650, PY + 156)
	photo_frame.size     = Vector2(332, 222)
	photo_frame.color    = Color(0.18, 0.14, 0.08)
	root.add_child(photo_frame)

	var photo := ColorRect.new()
	photo.position = Vector2(PX + 656, PY + 162)
	photo.size     = Vector2(320, 210)
	photo.color    = Color(0.82, 0.72, 0.52)  # fundo sépia claro
	root.add_child(photo)

	# Chão da foto (tom mais escuro)
	var photo_ground := ColorRect.new()
	photo_ground.position = Vector2(PX + 656, PY + 340)
	photo_ground.size     = Vector2(320, 32)
	photo_ground.color    = Color(0.60, 0.48, 0.32)
	root.add_child(photo_ground)

	# Loopy detalhado (tons sépia para parecer foto de jornal)
	_draw_loopy(root, PX + 816, PY + 355, 1.3, true)

	# Cantos da moldura (decoração de foto antiga)
	for cx in [PX + 652, PX + 970]:
		for cy in [PY + 158, PY + 368]:
			var corner := ColorRect.new()
			corner.position = Vector2(cx, cy)
			corner.size     = Vector2(10, 10)
			corner.color    = Color(0.10, 0.08, 0.05)
			root.add_child(corner)

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
