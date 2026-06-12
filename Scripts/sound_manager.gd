extends Node

## SoundManager - Autoload Singleton
## Sintetiza efeitos sonoros retrô em tempo real usando AudioStreamGenerator.

var pool_size: int = 8
var players: Array[AudioStreamPlayer] = []
var sample_rate: float = 22050.0
var bgm_player: AudioStreamPlayer = null

<<<<<<< HEAD
# Sons ambientais
var ambient_player: AudioStreamPlayer = null
var ambient_playback: AudioStreamGeneratorPlayback = null
var ambient_type: String = ""
var ambient_active: bool = false
var ambient_phase: float = 0.0
var ambient_time: float = 0.0
var ambient_volume_db: float = -18.0
var ambient_fade_tween: Tween = null

# Filtro BGM
var bgm_bus_idx: int = -1
var muffle_tween: Tween = null
var is_muffled: bool = false

=======
>>>>>>> 95a70239ae1677ac88b33fb622bcd3768c4c8119
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
		
<<<<<<< HEAD
	# Criar Bus BGM e adicionar filtro
	var existing_idx = AudioServer.get_bus_index("BGM")
	if existing_idx == -1:
		bgm_bus_idx = AudioServer.get_bus_count()
		AudioServer.add_bus(bgm_bus_idx)
		AudioServer.set_bus_name(bgm_bus_idx, "BGM")
		AudioServer.set_bus_send(bgm_bus_idx, "Master")
		
		var filter := AudioEffectLowPassFilter.new()
		filter.cutoff_hz = 20500.0
		AudioServer.add_bus_effect(bgm_bus_idx, filter, 0)
	else:
		bgm_bus_idx = existing_idx
		
	bgm_player = AudioStreamPlayer.new()
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	bgm_player.bus = "BGM"
=======
	bgm_player = AudioStreamPlayer.new()
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
>>>>>>> 95a70239ae1677ac88b33fb622bcd3768c4c8119
	add_child(bgm_player)
	bgm_player.finished.connect(func():
		if bgm_player.stream:
			bgm_player.play()
	)
<<<<<<< HEAD
	
	# Player de som ambiente (gerador contínuo)
	ambient_player = AudioStreamPlayer.new()
	var amb_gen := AudioStreamGenerator.new()
	amb_gen.mix_rate = sample_rate
	amb_gen.buffer_length = 0.5
	ambient_player.stream = amb_gen
	ambient_player.volume_db = ambient_volume_db
	add_child(ambient_player)
=======
>>>>>>> 95a70239ae1677ac88b33fb622bcd3768c4c8119

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
<<<<<<< HEAD

func set_muffled_audio(muffled: bool) -> void:
	if is_muffled == muffled:
		return
	is_muffled = muffled
	
	if muffle_tween and muffle_tween.is_valid():
		muffle_tween.kill()
		
	if bgm_bus_idx == -1:
		return
		
	var target_hz = 1200.0 if muffled else 20500.0
	var filter = AudioServer.get_bus_effect(bgm_bus_idx, 0) as AudioEffectLowPassFilter
	if not filter:
		return
		
	muffle_tween = create_tween()
	muffle_tween.tween_property(filter, "cutoff_hz", target_hz, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# ============================================================
# SONS AMBIENTAIS (sintetizados proceduralmente)
# ============================================================

func play_ambient(type: String) -> void:
	if type == "" or type == ambient_type:
		return
	
	ambient_type = type
	ambient_active = true
	ambient_time = 0.0
	ambient_phase = 0.0
	
	if not ambient_player.playing:
		ambient_player.play()
		ambient_playback = ambient_player.get_stream_playback()
	
	# Fade in suave
	if ambient_fade_tween and ambient_fade_tween.is_valid():
		ambient_fade_tween.kill()
	ambient_player.volume_db = -40.0
	ambient_fade_tween = create_tween()
	ambient_fade_tween.tween_property(ambient_player, "volume_db", ambient_volume_db, 1.5)

func stop_ambient() -> void:
	if not ambient_active:
		return
	
	if ambient_fade_tween and ambient_fade_tween.is_valid():
		ambient_fade_tween.kill()
	ambient_fade_tween = create_tween()
	ambient_fade_tween.tween_property(ambient_player, "volume_db", -40.0, 0.8)
	ambient_fade_tween.tween_callback(func():
		ambient_player.stop()
		ambient_active = false
		ambient_type = ""
	)

func _process(delta: float) -> void:
	if ambient_active and ambient_playback:
		_fill_ambient_buffer(delta)

func _fill_ambient_buffer(_delta: float) -> void:
	if not ambient_playback:
		return
	var frames_available := ambient_playback.get_frames_available()
	if frames_available <= 0:
		return
	
	var frames := PackedVector2Array()
	frames.resize(frames_available)
	
	for i in range(frames_available):
		ambient_time += 1.0 / sample_rate
		var sample := _generate_ambient_sample(ambient_type, ambient_time)
		var val: float = clamp(sample, -1.0, 1.0)
		frames[i] = Vector2(val, val)
	
	ambient_playback.push_buffer(frames)

func _generate_ambient_sample(type: String, t: float) -> float:
	var s := 0.0
	
	match type:
		"city":
			# Ruído rosa filtrado + tons graves periódicos (tráfego leve)
			var noise := randf_range(-1.0, 1.0) * 0.12
			var rumble := sin(t * 18.0) * 0.06 * (0.5 + 0.5 * sin(t * 0.3))
			var horn: float = sin(t * 280.0) * 0.03 * max(0.0, sin(t * 0.15) - 0.85) * 6.0
			s = noise + rumble + horn
		
		"wind_cold":
			# Vento gelado — ruído modulado em amplitude lenta
			var wind_mod := 0.5 + 0.5 * sin(t * 0.4)
			var gust := 0.5 + 0.5 * sin(t * 0.12 + 2.0)
			var noise := randf_range(-1.0, 1.0)
			s = noise * 0.15 * wind_mod * gust
			# Assobio do vento
			s += sin(t * 620.0 + sin(t * 1.8) * 200.0) * 0.04 * wind_mod
		
		"factory":
			# Máquinas — dente-de-serra LFO + batida rítmica
			var saw_phase := fmod(t * 45.0, TAU)
			var saw := (saw_phase / PI - 1.0) * 0.08
			var beat_t := fmod(t, 0.8)
			var clank := 0.0
			if beat_t < 0.03:
				clank = randf_range(-1.0, 1.0) * 0.25 * (1.0 - beat_t / 0.03)
			var hum := sin(t * 120.0) * 0.05 * (0.6 + 0.4 * sin(t * 0.5))
			s = saw + clank + hum
		
		"wind_high":
			# Vento alto nos telhados — sweep oscilatório
			var sweep := sin(t * 0.25) * 400.0 + 500.0
			var wind := sin(t * sweep) * 0.06
			var gust := randf_range(-1.0, 1.0) * 0.10 * (0.5 + 0.5 * sin(t * 0.35))
			s = wind + gust
		
		"echo_urban":
			# Eco urbano em becos — pulsos espaçados com reverb
			var noise := randf_range(-1.0, 1.0) * 0.06
			var drip_t := fmod(t, 2.3)
			var drip := 0.0
			if drip_t < 0.015:
				drip = sin(drip_t * 4800.0) * 0.20 * (1.0 - drip_t / 0.015)
			var echo := sin(t * 85.0) * 0.03 * (0.3 + 0.7 * sin(t * 0.18))
			s = noise + drip + echo
		
		"sewer":
			# Água escorrendo + gotas aleatórias
			var water_flow := randf_range(-1.0, 1.0) * 0.08 * (0.6 + 0.4 * sin(t * 0.6))
			var drip1_t := fmod(t, 1.7)
			var drip2_t := fmod(t + 0.8, 2.9)
			var drip := 0.0
			if drip1_t < 0.012:
				drip += sin(drip1_t * 5200.0) * 0.22 * (1.0 - drip1_t / 0.012)
			if drip2_t < 0.010:
				drip += sin(drip2_t * 6400.0) * 0.18 * (1.0 - drip2_t / 0.010)
			var rumble := sin(t * 28.0) * 0.04
			s = water_flow + drip + rumble
		
		"construction":
			# Metal rangendo + tons metálicos com vibrato
			var creak_freq := 220.0 + sin(t * 1.5) * 80.0
			var creak: float = sin(t * creak_freq) * 0.05 * max(0.0, sin(t * 0.4) - 0.3) * 1.4
			var noise := randf_range(-1.0, 1.0) * 0.06
			var clang_t := fmod(t, 3.2)
			var clang := 0.0
			if clang_t < 0.04:
				clang = sin(clang_t * 3200.0) * 0.20 * (1.0 - clang_t / 0.04)
			s = creak + noise * 0.5 + clang
		
		"park_wind":
			# Vento suave + folhas
			var breeze := randf_range(-1.0, 1.0) * 0.09 * (0.5 + 0.5 * sin(t * 0.28))
			var leaves: float = sin(t * 1200.0 + sin(t * 3.5) * 600.0) * 0.02 * max(0.0, sin(t * 0.5) - 0.4) * 2.5
			var bird_t := fmod(t, 5.5)
			var bird := 0.0
			if bird_t < 0.08:
				bird = sin(bird_t * 2800.0 + sin(bird_t * 80.0) * 600.0) * 0.10 * (1.0 - bird_t / 0.08)
			s = breeze + leaves + bird
		
		"metro":
			# Ecos subterrâneos — drone grave + ecos metálicos
			var drone := sin(t * 55.0) * 0.10 * (0.7 + 0.3 * sin(t * 0.2))
			var echo_t := fmod(t, 4.1)
			var echo := 0.0
			if echo_t < 0.06:
				echo = sin(echo_t * 1800.0) * 0.15 * (1.0 - echo_t / 0.06)
			var hum := sin(t * 100.0) * 0.03 + sin(t * 150.0) * 0.02
			var rumble := randf_range(-1.0, 1.0) * 0.04
			s = drone + echo + hum + rumble
		
		"epic_tension":
			# Tensão épica — drone ascendente + pulso rítmico
			var base_freq := 50.0 + sin(t * 0.08) * 15.0
			var drone := sin(t * base_freq) * 0.10
			var drone2 := sin(t * base_freq * 1.5) * 0.05
			var pulse_t := fmod(t, 1.2)
			var pulse := 0.0
			if pulse_t < 0.08:
				pulse = sin(pulse_t * 180.0) * 0.12 * (1.0 - pulse_t / 0.08)
			var tension := randf_range(-1.0, 1.0) * 0.05 * (0.5 + 0.5 * sin(t * 0.15))
			s = drone + drone2 + pulse + tension
	
	return s
=======
>>>>>>> 95a70239ae1677ac88b33fb622bcd3768c4c8119
