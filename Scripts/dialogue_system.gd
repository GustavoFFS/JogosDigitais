extends CanvasLayer
class_name DialogueSystem

## Sistema de Diálogos — Balões sobre Rob e Bog
## Exibe falas curtas com efeito de typing e avanço com ESPAÇO.
## Emite 'dialogue_finished' ao concluir todas as falas.

signal dialogue_finished

var _dialogues: Array = []
var _current_index: int = 0
var _typing: bool = false
var _typing_timer: float = 0.0
var _char_index: int = 0
var _full_text: String = ""
var _active: bool = false
var _waiting_input: bool = false

# Referências aos personagens (posições no mundo)
var _rob: CharacterBase = null
var _bog: CharacterBase = null
var _camera: Camera2D = null

# Nós visuais
var _balloon_container: Control = null
var _balloon_bg: ColorRect = null
var _balloon_border: ColorRect = null
var _speaker_label: Label = null
var _text_label: Label = null
var _advance_hint: Label = null
var _balloon_tail: ColorRect = null

# Cores dos personagens
const COLOR_ROB := Color(0.40, 0.75, 1.00)
const COLOR_BOG := Color(1.00, 0.60, 0.25)
const COLOR_BG := Color(0.06, 0.08, 0.14, 0.95)
const COLOR_BORDER_ROB := Color(0.30, 0.55, 0.85, 0.90)
const COLOR_BORDER_BOG := Color(0.85, 0.50, 0.18, 0.90)

const TYPING_SPEED: float = 0.028  # Segundos por caractere
const BALLOON_WIDTH: float = 420.0
const BALLOON_HEIGHT: float = 110.0

func _ready() -> void:
	layer = 15  # Acima do HUD
	_build_balloon()

func _build_balloon() -> void:
	_balloon_container = Control.new()
	_balloon_container.size = Vector2(BALLOON_WIDTH, BALLOON_HEIGHT)
	_balloon_container.visible = false
	_balloon_container.modulate.a = 0.0
	add_child(_balloon_container)

	# Fundo do balão
	_balloon_bg = ColorRect.new()
	_balloon_bg.size = Vector2(BALLOON_WIDTH, BALLOON_HEIGHT)
	_balloon_bg.position = Vector2.ZERO
	_balloon_bg.color = COLOR_BG
	_balloon_container.add_child(_balloon_bg)

	# Borda superior (cor muda conforme o speaker)
	_balloon_border = ColorRect.new()
	_balloon_border.size = Vector2(BALLOON_WIDTH, 3)
	_balloon_border.position = Vector2.ZERO
	_balloon_border.color = COLOR_BORDER_ROB
	_balloon_container.add_child(_balloon_border)

	# Borda inferior
	var border_bot := ColorRect.new()
	border_bot.size = Vector2(BALLOON_WIDTH, 2)
	border_bot.position = Vector2(0, BALLOON_HEIGHT - 2)
	border_bot.color = Color(0.15, 0.18, 0.28, 0.60)
	_balloon_container.add_child(border_bot)

	# Cauda do balão (triângulo simplificado com retângulos)
	_balloon_tail = ColorRect.new()
	_balloon_tail.size = Vector2(14, 14)
	_balloon_tail.position = Vector2(BALLOON_WIDTH / 2.0 - 7, BALLOON_HEIGHT)
	_balloon_tail.color = COLOR_BG
	_balloon_tail.rotation = deg_to_rad(45)
	_balloon_container.add_child(_balloon_tail)

	# Nome do personagem
	_speaker_label = Label.new()
	_speaker_label.position = Vector2(16, 8)
	_speaker_label.size = Vector2(BALLOON_WIDTH - 32, 24)
	_speaker_label.add_theme_font_size_override("font_size", 16)
	_speaker_label.add_theme_color_override("font_color", COLOR_ROB)
	_balloon_container.add_child(_speaker_label)

	# Texto do diálogo
	_text_label = Label.new()
	_text_label.position = Vector2(16, 36)
	_text_label.size = Vector2(BALLOON_WIDTH - 32, 48)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.add_theme_font_size_override("font_size", 15)
	_text_label.add_theme_color_override("font_color", Color(0.90, 0.92, 0.98))
	_balloon_container.add_child(_text_label)

	# Hint de avanço
	_advance_hint = Label.new()
	_advance_hint.text = "▶  ESPAÇO"
	_advance_hint.position = Vector2(16, BALLOON_HEIGHT - 24)
	_advance_hint.size = Vector2(BALLOON_WIDTH - 32, 20)
	_advance_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_advance_hint.add_theme_font_size_override("font_size", 11)
	_advance_hint.add_theme_color_override("font_color", Color(0.40, 0.42, 0.55))
	_advance_hint.modulate.a = 0.0
	_balloon_container.add_child(_advance_hint)

func start_dialogue(dialogues: Array, rob: CharacterBase, bog: CharacterBase, cam: Camera2D) -> void:
	if dialogues.is_empty():
		dialogue_finished.emit()
		return
	_dialogues = dialogues
	_rob = rob
	_bog = bog
	_camera = cam
	_current_index = 0
	_active = true
	_show_current_line()

func _show_current_line() -> void:
	if _current_index >= _dialogues.size():
		_finish()
		return

	var line: Dictionary = _dialogues[_current_index]
	var speaker: String = line.get("speaker", "Rob")
	_full_text = line.get("text", "")

	# Configura aparência pelo speaker
	var is_rob := speaker == "Rob"
	_speaker_label.text = speaker.to_upper()
	_speaker_label.add_theme_color_override("font_color", COLOR_ROB if is_rob else COLOR_BOG)
	_balloon_border.color = COLOR_BORDER_ROB if is_rob else COLOR_BORDER_BOG

	# Reset do typing
	_text_label.text = ""
	_char_index = 0
	_typing = true
	_typing_timer = 0.0
	_waiting_input = false
	_advance_hint.modulate.a = 0.0

	# Mostra o balão com fade-in
	_balloon_container.visible = true
	var tw := create_tween()
	tw.tween_property(_balloon_container, "modulate:a", 1.0, 0.2)

	# Toca um som de "blip" ao iniciar fala
	SoundManager.play_sfx("switch")

func _process(delta: float) -> void:
	if not _active:
		if _balloon_container and _balloon_container.visible:
			_update_balloon_position()
		return

	_update_balloon_position()

	if _typing:
		_typing_timer += delta
		while _typing_timer >= TYPING_SPEED and _char_index < _full_text.length():
			_typing_timer -= TYPING_SPEED
			_char_index += 1
			_text_label.text = _full_text.substr(0, _char_index)

		if _char_index >= _full_text.length():
			_typing = false
			_waiting_input = true
			_text_label.text = _full_text
			# Mostra hint de avanço
			var tw := create_tween()
			tw.tween_property(_advance_hint, "modulate:a", 1.0, 0.25)

	# Input para avançar
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		if _typing:
			# Pula a animação e mostra o texto completo
			_typing = false
			_char_index = _full_text.length()
			_text_label.text = _full_text
			_waiting_input = true
			_advance_hint.modulate.a = 1.0
		elif _waiting_input:
			_waiting_input = false
			_current_index += 1
			if _current_index >= _dialogues.size():
				_finish()
			else:
				# Fade out rápido e mostra próxima fala
				var tw := create_tween()
				tw.tween_property(_balloon_container, "modulate:a", 0.0, 0.12)
				tw.tween_callback(_show_current_line)

func _update_balloon_position() -> void:
	if not _camera or not _rob or not _bog:
		return

	# Determina qual personagem está falando
	var line: Dictionary = _dialogues[_current_index] if _current_index < _dialogues.size() else {}
	var speaker: String = line.get("speaker", "Rob")
	var target: CharacterBase = _rob if speaker == "Rob" else _bog

	# Converte posição do mundo para posição na tela
	var viewport := get_viewport()
	if not viewport:
		return
	var canvas_transform := viewport.get_canvas_transform()
	var screen_pos: Vector2 = canvas_transform * target.global_position

	# Posiciona o balão acima do personagem
	var balloon_x := screen_pos.x - BALLOON_WIDTH / 2.0
	var balloon_y := screen_pos.y - BALLOON_HEIGHT - 80  # 80px acima do personagem

	# Clampa para não sair da tela
	balloon_x = clamp(balloon_x, 10, 1152 - BALLOON_WIDTH - 10)
	balloon_y = clamp(balloon_y, 10, 648 - BALLOON_HEIGHT - 30)

	_balloon_container.position = Vector2(balloon_x, balloon_y)

	# Ajusta a posição da cauda para apontar pro personagem
	var tail_x := screen_pos.x - balloon_x - 7
	tail_x = clamp(tail_x, 20, BALLOON_WIDTH - 34)
	_balloon_tail.position = Vector2(tail_x, BALLOON_HEIGHT - 4)

func _finish() -> void:
	_active = false
	var tw := create_tween()
	tw.tween_property(_balloon_container, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func():
		_balloon_container.visible = false
		dialogue_finished.emit()
	)

func is_active() -> bool:
	return _active or (_balloon_container and _balloon_container.visible)
