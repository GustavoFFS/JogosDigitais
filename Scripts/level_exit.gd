extends Area2D
class_name LevelExit

var _time: float = 0.0
var portal_color: Color = Color(0.2, 0.95, 0.5) # Verde esmeralda neon

var _particles: CPUParticles2D
var _arrow: Label

func _ready() -> void:
	# 1. Colisor (mesmo tamanho anterior)
	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40, 60)
	shape_node.shape = rect
	add_child(shape_node)

	# 2. Camadas de Colisão
	collision_layer = 0
	collision_mask = 1

	# 3. Emissor de Partículas (Efeito Mágico)
	_particles = CPUParticles2D.new()
	_particles.amount = 25
	_particles.lifetime = 1.2
	_particles.preprocess = 1.0
	_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_particles.emission_rect_extents = Vector2(18, 5)
	_particles.position = Vector2(0, 30) # Base do portal
	_particles.direction = Vector2(0, -1)
	_particles.spread = 20.0
	_particles.gravity = Vector2(0, -45) # Flutuando suavemente para cima
	_particles.initial_velocity_min = 25.0
	_particles.initial_velocity_max = 50.0
	_particles.damping_min = 10.0
	_particles.damping_max = 20.0
	
	# Curva de escala (diminui à medida que sobe)
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(0.7, 0.8))
	curve.add_point(Vector2(1.0, 0.0))
	_particles.scale_amount_curve = curve
	_particles.scale_amount_min = 2.5
	_particles.scale_amount_max = 4.5
	
	# Gradiente de cor (verde para ciano translúcido)
	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		portal_color.lightened(0.2),
		Color(0.1, 0.8, 0.9, 0.8),
		Color(0.1, 0.8, 0.9, 0.0)
	])
	grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	_particles.color_ramp = grad
	
	add_child(_particles)

	# 4. Seta indicadora flutuante
	_arrow = Label.new()
	_arrow.text = "▼"
	_arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_arrow.size = Vector2(40, 20)
	_arrow.position = Vector2(-20, -60)
	_arrow.add_theme_font_size_override("font_size", 16)
	_arrow.add_theme_color_override("font_color", portal_color.lightened(0.3))
	add_child(_arrow)

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()
	
	# Animação da seta flutuante
	if _arrow:
		var float_offset = sin(_time * 5.0) * 4.0
		_arrow.position.y = -60 + float_offset
		var pulse_val = 0.6 + 0.4 * sin(_time * 5.0)
		_arrow.modulate.a = pulse_val

func _draw() -> void:
	var center := Vector2.ZERO
	var size := Vector2(20, 30) # Raio X e Y do portal
	
	# 1. Desenha anéis concêntricos de brilho elíptico (bloom)
	var glow_layers := 5
	for i in range(glow_layers):
		var pulse_scale = 1.0 + 0.06 * sin(_time * 4.0 + i)
		var current_size = size * (1.0 + i * 0.18) * pulse_scale
		var alpha = 0.18 / (i + 1.0)
		var thickness = 2.0 + i
		draw_ellipse_border(center, current_size, Color(portal_color.r, portal_color.g, portal_color.b, alpha), thickness)

	# 2. Desenha o preenchimento translúcido central
	draw_ellipse_filled(center, size, Color(portal_color.r, portal_color.g, portal_color.b, 0.15 + 0.05 * sin(_time * 3.0)))
	
	# 3. Desenha os filetes de energia em espiral giratória
	var swirl_count := 3
	for s in range(swirl_count):
		var angle_offset = s * (PI * 2.0 / swirl_count) - _time * 3.0
		var points := PackedVector2Array()
		var steps := 16
		for step in range(steps):
			var t = step / float(steps - 1)
			var angle = angle_offset + t * PI * 1.5
			var r_scale = 1.0 - t * 0.95
			var px = size.x * r_scale * cos(angle)
			var py = size.y * r_scale * sin(angle)
			points.append(Vector2(px, py))
		
		draw_polyline(points, Color(portal_color.r * 1.3, portal_color.g * 1.3, portal_color.b * 1.3, 0.65 * (1.0 - s * 0.1)), 1.5, true)

func draw_ellipse_border(center: Vector2, radii: Vector2, color: Color, thickness: float) -> void:
	var points := PackedVector2Array()
	var steps := 32
	for i in range(steps + 1):
		var angle = i * (PI * 2.0) / steps
		points.append(center + Vector2(radii.x * cos(angle), radii.y * sin(angle)))
	draw_polyline(points, color, thickness, true)

func draw_ellipse_filled(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	var steps := 32
	for i in range(steps):
		var angle = i * (PI * 2.0) / steps
		points.append(center + Vector2(radii.x * cos(angle), radii.y * sin(angle)))
	draw_polygon(points, PackedColorArray([color]))
