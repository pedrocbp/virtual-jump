extends Node

const Design := preload("res://scripts/ui/design.gd")

signal pause_requested

const SAMPLE_RATE := 11025
var muted: bool:
	get:
		return bool(SaveManager.settings.muted)
var transitioning := false
var _sounds: Dictionary = {}
var _voices: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer
var _overlay: ColorRect
var _voice_index := 0
var _app_focused := true
var settings_panel: CanvasLayer
var _audio_enabled := true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# O Moto G35 apresentou SIGSEGV em AudioTrack com AudioStreamWAV criado
	# em tempo de execucao. WAVs importados pelo Godot sao mais compativeis.
	_sounds["tap"] = load("res://assets/audio/tap.wav")
	_sounds["land"] = load("res://assets/audio/land.wav")
	_sounds["death"] = load("res://assets/audio/death.wav")
	_sounds["win"] = load("res://assets/audio/win.wav")
	for i in range(4):
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -18.0
		add_child(voice)
		_voices.append(voice)
	_music = AudioStreamPlayer.new()
	_music.stream = load("res://assets/audio/music.wav")
	if _music.stream is AudioStreamWAV:
		var music_stream := _music.stream as AudioStreamWAV
		music_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		music_stream.loop_end = music_stream.data.size() / 2
	_music.volume_db = -29.0
	add_child(_music)
	_music.play()
	SaveManager.settings_changed.connect(apply_settings)
	apply_settings()
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_overlay = ColorRect.new()
	layer.add_child(_overlay)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = _transition_color()
	_overlay.modulate.a = 0
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Sons próprios, sintetizados uma vez; não há arquivos/licenças externos.
func _tone(notes: Array, note_length: float, looped: bool = false) -> AudioStreamWAV:
	var data := PackedByteArray()
	var count := int(SAMPLE_RATE * note_length * notes.size())
	data.resize(count * 2)
	for index in range(count):
		var time := float(index) / SAMPLE_RATE
		var note_index := mini(int(time / note_length), notes.size() - 1)
		var phase := fmod(time, note_length) / note_length
		var envelope := sin(phase * PI) * (0.6 if looped else (1.0 - phase))
		var wave := sin(TAU * float(notes[note_index]) * time)
		if looped:
			wave = wave * 0.65 + sin(TAU * float(notes[note_index]) * 1.5 * time) * 0.2
		var sample := int(wave * envelope * 26000.0)
		data[index * 2] = sample & 255
		data[index * 2 + 1] = (sample >> 8) & 255
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.data = data
	if looped:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = count
	return stream

func play_sound(kind: String) -> void:
	if not _audio_enabled or _voices.is_empty() or muted or not _app_focused or not SaveManager.settings.sfx_enabled or float(SaveManager.settings.master_volume) <= 0 or float(SaveManager.settings.sfx_volume) <= 0 or not _sounds.has(kind):
		return
	var voice := _voices[_voice_index % _voices.size()]
	_voice_index += 1
	voice.stream = _sounds[kind]
	voice.play()

func toggle_sound() -> void:
	SaveManager.set_setting("muted", not muted)

func apply_settings() -> void:
	var master := float(SaveManager.settings.master_volume)
	var music := master * float(SaveManager.settings.music_volume)
	var effects := master * float(SaveManager.settings.sfx_volume)
	if is_instance_valid(_music):
		_music.volume_db = -29.0 + linear_to_db(maxf(music, 0.0001))
		_music.stream_paused = muted or not _app_focused or not SaveManager.settings.music_enabled or music <= 0
	for voice in _voices:
		voice.volume_db = -18.0 + linear_to_db(maxf(effects, 0.0001))
	if is_instance_valid(_overlay):
		_overlay.color = _transition_color()
	if muted or not SaveManager.settings.sfx_enabled or effects <= 0:
		for voice in _voices:
			voice.stop()


func _transition_color() -> Color:
	return Design.native_color(Design.INK, true)

func open_settings() -> void:
	if transitioning or is_instance_valid(settings_panel):
		return
	settings_panel = load("res://scripts/ui/settings_panel.gd").new()
	add_child(settings_panel)

func _exit_tree() -> void:
	for voice in _voices:
		voice.stop()
		voice.stream = null
	if is_instance_valid(_music):
		_music.stop()
		_music.stream = null
	_sounds.clear()

func vibrate(milliseconds: int = 25) -> void:
	if OS.has_feature("android") and _app_focused and SaveManager.settings.vibration_enabled:
		Input.vibrate_handheld(milliseconds)

func change_scene(path: String) -> void:
	if transitioning:
		return
	transitioning = true
	get_tree().paused = true
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(_overlay, "modulate:a", 1.0, 0.13)
	await tween.finished
	var error := get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Não foi possível abrir: " + path)
	await get_tree().process_frame
	get_tree().paused = false
	tween = create_tween()
	tween.tween_property(_overlay, "modulate:a", 0.0, 0.18)
	await tween.finished
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transitioning = false

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not transitioning:
		if is_instance_valid(settings_panel):
			settings_panel.call("go_back")
		else:
			pause_requested.emit()
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_app_focused = false
		if is_instance_valid(_music):
			_music.stream_paused = true
		if not get_tree().paused:
			pause_requested.emit()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN and is_instance_valid(_music):
		_app_focused = true
		apply_settings()
