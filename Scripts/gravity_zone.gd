extends Area2D
class_name GravityZone

## Zona que inverte a gravidade do personagem ao entrar.

@export var gravity_scale: float = -0.4  # negativo = invertido
@export var width: float = 64.0
@export var height: float = 64.0

var _time: float = 0.0
var _arrows: Array[Label] = []
var _bg: ColorRect
var _borders: Array[ColorRect] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_setup_visuals()

func _setup_visuals() -> void:
	# 1. Fundo roxo translúcido e pulsante
	_bg = ColorRect.new()
	_bg.size = Vector2(width, height)
	_bg.position = Vector2(-width / 2.0, -height / 2.0)
	_bg.color = Color(0.6, 0.2, 1.0, 0.24)
	add_child(_bg)

	# 2. Bordas brilhantes (campo de energia)
	var border_thickness: float = 2.0
	var border_color: Color = Color(0.78, 0.4, 1.0, 0.65)
	
	# Borda Superior
	var border_t := ColorRect.new()
	border_t.size = Vector2(width, border_thickness)
	border_t.position = Vector2(-width / 2.0, -height / 2.0)
	border_t.color = border_color
	add_child(border_t)
	_borders.append(border_t)

	# Borda Inferior
	var border_b := ColorRect.new()
	border_b.size = Vector2(width, border_thickness)
	border_b.position = Vector2(-width / 2.0, height / 2.0 - border_thickness)
	border_b.color = border_color
	add_child(border_b)
	_borders.append(border_b)

	# Borda Esquerda
	var border_l := ColorRect.new()
	border_l.size = Vector2(border_thickness, height)
	border_l.position = Vector2(-width / 2.0, -height / 2.0)
	border_l.color = border_color
	add_child(border_l)
	_borders.append(border_l)

	# Borda Direita
	var border_r := ColorRect.new()
	border_r.size = Vector2(border_thickness, height)
	border_r.position = Vector2(width / 2.0 - border_thickness, -height / 2.0)
	border_r.color = border_color
	add_child(border_r)
	_borders.append(border_r)

	# 3. Grid de setas indicativas que sobem continuamente
	var col_spacing: float = 32.0
	var row_spacing: float = 40.0
	
	var cols: int = int(max(1.0, floor(width / col_spacing)))
	var rows: int = int(max(1.0, floor(height / row_spacing)))
	
	var actual_col_spacing: float = width / cols
	var actual_row_spacing: float = height / rows

	var arrow_char: String = "▲" if gravity_scale < 0 else "▼"

	for c in range(cols):
		for r in range(rows):
			var arrow := Label.new()
			arrow.text = arrow_char
			arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			arrow.size = Vector2(24, 20)
			
			# Espaçamento e offset randômico para as setas fluírem organicamente
			var px: float = -width / 2.0 + (c + 0.5) * actual_col_spacing - 12.0
			var py: float = -height / 2.0 + (r + randf()) * actual_row_spacing - 10.0
			arrow.position = Vector2(px, py)
			
			arrow.add_theme_font_size_override("font_size", 12)
			arrow.add_theme_color_override("font_color", Color(0.85, 0.5, 1.0, 0.75))
			
			add_child(arrow)
			_arrows.append(arrow)

func _process(delta: float) -> void:
	_time += delta

	# Fundo pulsa suavemente
	if _bg:
		_bg.color.a = 0.20 + 0.08 * sin(_time * 4.0)

	# Bordas pulsam com o campo de força
	var border_alpha: float = 0.5 + 0.25 * sin(_time * 4.0)
	for border in _borders:
		border.color.a = border_alpha

	# Movimento e fade suave das setas indicativas
	# A velocidade de subida/descida é proporcional à escala da gravidade da zona
	var scroll_speed: float = -gravity_scale * 120.0
	var half_h: float = height / 2.0
	var fade_dist: float = min(28.0, height * 0.35)

	for arrow in _arrows:
		arrow.position.y -= scroll_speed * delta

		# Loop infinito nas extremidades da área
		if scroll_speed > 0: # Subindo
			if arrow.position.y < -half_h - 15:
				arrow.position.y = half_h
		else: # Descendo
			if arrow.position.y > half_h:
				arrow.position.y = -half_h - 15

		# Fade suave próximo aos limites superior/inferior
		var local_y: float = arrow.position.y + 10.0
		var dist_to_edge: float = half_h - abs(local_y)
		var alpha: float = clamp(dist_to_edge / fade_dist, 0.0, 1.0) * 0.75
		arrow.modulate.a = alpha

func _on_body_entered(body: Node) -> void:
	if body is CharacterBase:
		body.gravity_mult = gravity_scale

func _on_body_exited(body: Node) -> void:
	if body is CharacterBase:
		body.gravity_mult = 1.0  # restaura ao sair
