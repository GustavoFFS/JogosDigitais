extends Control

## Main Menu - Tela de titulo do Lost & Loopy

var title_label: Label
var subtitle_label: Label
var start_button: Button
var quit_button: Button
var controls_label: Label
var bg: ColorRect

# Animacao do titulo
var time: float = 0.0

func _ready():
	_build_ui()

func _process(delta: float):
	time += delta
	# Titulo com leve animacao de "loopy" (balanco)
	if title_label:
		title_label.rotation = sin(time * 1.5) * 0.03
		title_label.position.y = 100 + sin(time * 2.0) * 5.0

func _build_ui():
	# Background
	bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.08, 0.1, 0.18)
	add_child(bg)

	# Estrelas decorativas no fundo
	for i in range(30):
		var star = ColorRect.new()
		star.size = Vector2(2, 2)
		star.position = Vector2(randf() * 1152, randf() * 648)
		star.color = Color(1, 1, 1, randf() * 0.5 + 0.1)
		add_child(star)

	# Titulo
	title_label = Label.new()
	title_label.text = "Lost & Loopy"
	title_label.position = Vector2(280, 100)
	title_label.size = Vector2(600, 80)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 64)
	title_label.add_theme_color_override("font_color", Color(0.3, 0.85, 0.45))
	title_label.pivot_offset = Vector2(300, 40)
	add_child(title_label)

	# Subtitulo
	subtitle_label = Label.new()
	subtitle_label.text = "Encontre seu amigo perdido!"
	subtitle_label.position = Vector2(300, 200)
	subtitle_label.size = Vector2(560, 40)
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 22)
	subtitle_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.75))
	add_child(subtitle_label)

	# High concept
	var concept = Label.new()
	concept.text = "\"Um jogo onde você nunca controla da mesma forma duas vezes.\""
	concept.position = Vector2(220, 240)
	concept.size = Vector2(720, 30)
	concept.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	concept.add_theme_font_size_override("font_size", 15)
	concept.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3, 0.7))
	add_child(concept)

	# Container dos botoes
	var btn_container = VBoxContainer.new()
	btn_container.position = Vector2(426, 320)
	btn_container.size = Vector2(300, 200)
	btn_container.add_theme_constant_override("separation", 15)
	add_child(btn_container)

	# Botao Jogar
	start_button = Button.new()
	start_button.text = "Jogar"
	start_button.custom_minimum_size = Vector2(300, 55)
	start_button.add_theme_font_size_override("font_size", 26)
	start_button.pressed.connect(_on_start)
	btn_container.add_child(start_button)

	# Botao Sair
	quit_button = Button.new()
	quit_button.text = "Sair"
	quit_button.custom_minimum_size = Vector2(300, 45)
	quit_button.add_theme_font_size_override("font_size", 20)
	quit_button.pressed.connect(_on_quit)
	btn_container.add_child(quit_button)

	# Controles
	controls_label = Label.new()
	controls_label.text = "Controles:\nA/D ou Setas = Mover  |  Espaço = Pular  |  TAB = Trocar Personagem"
	controls_label.position = Vector2(200, 520)
	controls_label.size = Vector2(760, 60)
	controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_label.add_theme_font_size_override("font_size", 15)
	controls_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.58))
	add_child(controls_label)

	# Creditos
	var credits = Label.new()
	credits.text = "Lost & Loopy - Projeto Jogos Digitais 2026"
	credits.position = Vector2(350, 600)
	credits.size = Vector2(460, 30)
	credits.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits.add_theme_font_size_override("font_size", 12)
	credits.add_theme_color_override("font_color", Color(0.35, 0.35, 0.4))
	add_child(credits)

func _on_start():
	GameManager.start_game()
	get_tree().change_scene_to_file("res://Scenes/scene1.tscn")

func _on_quit():
	get_tree().quit()
