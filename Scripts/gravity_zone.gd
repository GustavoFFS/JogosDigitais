extends Area2D
class_name GravityZone

## Zona que inverte a gravidade do personagem ao entrar.

@export var gravity_scale: float = -0.4  # negativo = invertido
@export var width: float = 64.0
@export var height: float = 64.0

var _time: float = 0.0
var _wind_lines: Array[Dictionary] = []
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

	# 3. Linhas de vento ondulantes desenhadas vetorialmente
	var num_lines: int = int(max(2.0, width / 24.0))
	for i in range(num_lines):
		_wind_lines.append({
			"x": -width / 2.0 + (i + 0.5) * (width / num_lines),
			"y": randf() * height - height / 2.0,
			"speed": randf_range(60.0, 120.0),
			"phase": randf() * PI * 2.0,
			"length": randf_range(15.0, 35.0)
		})

func _process(delta: float) -> void:
	_time += delta

	if _bg:
		_bg.color.a = 0.20 + 0.08 * sin(_time * 4.0)

	var border_alpha: float = 0.5 + 0.25 * sin(_time * 4.0)
	for border in _borders:
		border.color.a = border_alpha

	var dir: float = -1.0 if gravity_scale < 0 else 1.0
	var half_h: float = height / 2.0

	for line in _wind_lines:
		line["y"] += dir * line["speed"] * delta
		line["phase"] += delta * 5.0

		if dir < 0 and line["y"] < -half_h - 20:
			line["y"] = half_h + 20
		elif dir > 0 and line["y"] > half_h + 20:
			line["y"] = -half_h - 20

	queue_redraw()

func _draw() -> void:
	var color := Color(0.85, 0.5, 1.0, 0.6)
	var half_h: float = height / 2.0
	
	for line in _wind_lines:
		var line_pts: PackedVector2Array = PackedVector2Array()
		var segments: int = 8
		for i in range(segments):
			var t: float = float(i) / float(segments - 1)
			var y_offset: float = float(line["length"]) * t
			var x_offset: float = sin(float(line["phase"]) + t * PI) * 5.0
			var pt_y: float = float(line["y"]) - y_offset * (-1.0 if gravity_scale > 0 else 1.0)
			line_pts.append(Vector2(float(line["x"]) + x_offset, pt_y))
		
		var local_y: float = float(line["y"]) - float(line["length"])/2.0 * (-1.0 if gravity_scale > 0 else 1.0)
		var dist_to_edge: float = half_h - float(abs(local_y))
		var fade_dist: float = min(28.0, height * 0.35)
		var alpha: float = clamp(dist_to_edge / fade_dist, 0.0, 1.0) * 0.8
		color.a = alpha
		
		for i in range(segments - 1):
			draw_line(line_pts[i], line_pts[i+1], color, 2.0, true)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBase:
		body.gravity_mult = gravity_scale
	elif body is RigidBody2D:
		body.set_meta("original_gravity_scale", body.gravity_scale)
		body.gravity_scale = gravity_scale

func _on_body_exited(body: Node) -> void:
	if body is CharacterBase:
		body.gravity_mult = 1.0  # restaura ao sair
	elif body is RigidBody2D:
		if body.has_meta("original_gravity_scale"):
			body.gravity_scale = body.get_meta("original_gravity_scale")
		else:
			body.gravity_scale = 1.2
