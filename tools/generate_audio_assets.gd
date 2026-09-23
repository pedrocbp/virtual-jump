extends SceneTree

const SAMPLE_RATE := 11025
const TAU_F := 6.283185307179586

func _initialize() -> void:
	_generate_effect("tap", [660.0], 0.055)
	_generate_effect("land", [420.0, 630.0], 0.045)
	_generate_effect("death", [210.0, 145.0, 85.0], 0.06)
	_generate_effect("win", [523.25, 659.25, 783.99, 1046.5], 0.12)
	_generate_effect("music", [130.81, 164.81, 196.0, 164.81, 110.0, 146.83, 196.0, 146.83], 0.8, true)
	quit()

func _generate_effect(name: String, notes: Array, note_length: float, looped: bool = false) -> void:
	var sample_count := int(SAMPLE_RATE * note_length * notes.size())
	var pcm := PackedByteArray()
	pcm.resize(sample_count * 2)
	for index in range(sample_count):
		var time := float(index) / SAMPLE_RATE
		var note_index := mini(int(time / note_length), notes.size() - 1)
		var phase := fmod(time, note_length) / note_length
		var envelope := sin(phase * PI) * (0.6 if looped else (1.0 - phase))
		var wave := sin(TAU_F * float(notes[note_index]) * time)
		if looped:
			wave = wave * 0.65 + sin(TAU_F * float(notes[note_index]) * 1.5 * time) * 0.2
		var sample := int(wave * envelope * 26000.0)
		pcm[index * 2] = sample & 255
		pcm[index * 2 + 1] = (sample >> 8) & 255
	_write_wav("res://assets/audio/" + name + ".wav", pcm)

func _write_wav(path: String, pcm: PackedByteArray) -> void:
	var bytes := PackedByteArray()
	_append_text(bytes, "RIFF")
	_append_u32(bytes, 36 + pcm.size())
	_append_text(bytes, "WAVE")
	_append_text(bytes, "fmt ")
	_append_u32(bytes, 16)
	_append_u16(bytes, 1)
	_append_u16(bytes, 1)
	_append_u32(bytes, SAMPLE_RATE)
	_append_u32(bytes, SAMPLE_RATE * 2)
	_append_u16(bytes, 2)
	_append_u16(bytes, 16)
	_append_text(bytes, "data")
	_append_u32(bytes, pcm.size())
	bytes.append_array(pcm)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_buffer(bytes)
		file.close()

func _append_text(bytes: PackedByteArray, value: String) -> void:
	bytes.append_array(value.to_ascii_buffer())

func _append_u16(bytes: PackedByteArray, value: int) -> void:
	bytes.append(value & 255)
	bytes.append((value >> 8) & 255)

func _append_u32(bytes: PackedByteArray, value: int) -> void:
	bytes.append(value & 255)
	bytes.append((value >> 8) & 255)
	bytes.append((value >> 16) & 255)
	bytes.append((value >> 24) & 255)
