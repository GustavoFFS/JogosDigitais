extends Node

## SoundManager - Autoload Singleton
## Sintetiza efeitos sonoros retrô em tempo real usando AudioStreamGenerator.

var pool_size: int = 8
var players: Array[AudioStreamPlayer] = []
var sample_rate: float = 22050.0
var bgm_player: AudioStreamPlayer = null

func _ready() -> void:
	# Configura modo de processamento para tocar sons mesmo com jogo pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	for i in range(pool_size):
		var player := AudioStreamPlayer.new()
		var generator := AudioStreamGenerator.new()
		generator.mix_rate = sample_rate
		generator.buffer_length = 1.0 # Buffer de até 1 segundo
		player.stream = generator
		add_child(player)
		players.append(player)
		
	bgm_player = AudioStreamPlayer.new()
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(bgm_player)
	bgm_player.finished.connect(func():
		if bgm_player.stream:
			bgm_player.play()
	)

func play_sfx(type: String) -> void:
	# Acha um player que não esteja tocando
	var player: AudioStreamPlayer = null
	for p in players:
		if not p.playing:
			player = p
			break
	if player == null:
		# Se todos estiverem ocupados, rouba o primeiro
		player = players[0]
		
	player.stop()
	player.play()
	
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	if playback:
		_generate_sfx(type, playback)

func _generate_sfx(type: String, playback: AudioStreamGeneratorPlayback) -> void:
	var frames_available := playback.get_frames_available()
	if frames_available <= 0:
		return
		
	var duration := 0.15
	match type:
		"jump":
			duration = 0.12
		"dash":
			duration = 0.14
		"impact":
			duration = 0.35
		"collect":
			duration = 0.28
		"switch":
			duration = 0.08
		"death":
			duration = 0.50
		"victory":
			duration = 0.90
		"boost":
			duration = 0.18
			
	var num_frames := int(duration * sample_rate)
	num_frames = min(num_frames, frames_available)
	
	var frames := PackedVector2Array()
	frames.resize(num_frames)
	
	var phase := 0.0
	
	for i in range(num_frames):
		var t := float(i) / sample_rate
		var vol := 1.0
		var sample := 0.0
		
		match type:
			"jump":
				# Sweep de frequência ascendente rápida
				var freq = lerp(240.0, 680.0, t / duration)
				sample = sin(phase)
				phase += 2.0 * PI * freq / sample_rate
				vol = 0.6 * (1.0 - t / duration)
				
			"dash":
				# Ruído branco com decaimento exponencial rápido
				sample = randf_range(-1.0, 1.0)
				# Filtro passa-alta básico: subtrai amostra anterior (simulado por variação de fase/ruído)
				if i > 0:
					sample = sample - randf_range(-0.5, 0.5)
				vol = 0.7 * exp(-7.5 * t / duration)
				
			"impact":
				# Tremor grave: dente-de-serra grave + ruído misturado
				var freq = lerp(140.0, 35.0, t / duration)
				var saw = (phase / PI) - 1.0
				var noise = randf_range(-1.0, 1.0)
				sample = lerp(saw, noise, 0.3)
				phase += 2.0 * PI * freq / sample_rate
				vol = 0.8 * (1.0 - t / duration)
				
			"collect":
				# Chime duplo brilhante: nota C5 seguida de G5 com vibrato
				var freq = 523.25 # C5
				if t > 0.09:
					freq = 783.99 # G5
				# Onda quadrada leve para brilho retrô
				var sine = sin(phase)
				var sq = 1.0 if sine > 0.0 else -1.0
				sample = lerp(sine, sq, 0.2)
				phase += 2.0 * PI * freq / sample_rate
				vol = 0.5 * (1.0 - t / duration)
				
			"switch":
				# Blip curto e limpo de transição
				var freq = lerp(500.0, 300.0, t / duration)
				sample = sin(phase)
				phase += 2.0 * PI * freq / sample_rate
				vol = 0.5 * (1.0 - t / duration)
				
			"death":
				# Pitch bend melancólico descendente com onda dente-de-serra
				var freq = lerp(320.0, 60.0, t / duration)
				var saw = (phase / PI) - 1.0
				sample = saw
				phase += 2.0 * PI * freq / sample_rate
				vol = 0.75 * (1.0 - t / duration)
				
			"victory":
				# Jingle musical: C5 (0-0.2s) -> E5 (0.2-0.4s) -> G5 (0.4-0.6s) -> C6 (0.6s em diante)
				var freq = 523.25 # C5
				if t > 0.6:
					freq = 1046.50 # C6
				elif t > 0.4:
					freq = 783.99 # G5
				elif t > 0.2:
					freq = 659.25 # E5
				
				# Onda triangular/quadrada para soar chiptune clássico
				var sine = sin(phase)
				var sq = 1.0 if sine > 0.0 else -1.0
				sample = lerp(sine, sq, 0.25)
				phase += 2.0 * PI * freq / sample_rate
				vol = 0.5 * (1.0 - t / duration)
				
			"boost":
				# Pitch ascendente senoidal rápido e elástico
				var freq = lerp(300.0, 950.0, sin(t / duration * PI * 0.5))
				sample = sin(phase)
				phase += 2.0 * PI * freq / sample_rate
				vol = 0.6 * (1.0 - t / duration)

		if phase > 2.0 * PI:
			phase = fmod(phase, 2.0 * PI)
			
		var val :float = clamp(sample * vol, -1.0, 1.0)
		frames[i] = Vector2(val, val)
		
	playback.push_buffer(frames)

func play_bgm(stream_path: String, volume_db: float = -12.0) -> void:
	if not bgm_player:
		return
	if bgm_player.playing and bgm_player.stream and bgm_player.stream.resource_path == stream_path:
		return
	
	var stream = load(stream_path)
	if stream:
		if "loop" in stream:
			stream.loop = true
		bgm_player.stream = stream
		bgm_player.volume_db = volume_db
		bgm_player.play()

func stop_bgm() -> void:
	if bgm_player:
		bgm_player.stop()
