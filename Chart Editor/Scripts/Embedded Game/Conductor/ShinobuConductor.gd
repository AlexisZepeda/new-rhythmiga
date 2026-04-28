class_name ShinobuConductor
extends Node

signal finished
signal loaded_new_stream

@export_file_path var sound_file: String = ""
## Offset (in milliseconds) of when the 1st beat of the song is in the audio
## file. [code]5000[/code] means the 1st beat happens 5 seconds into the track.
@export var first_beat_offset_ms: int = 1540: set=_set_offset_ticks

var BPM: float = 155.0: set=_set_seconds_per_tick


var bgm_group: ShinobuGroup
var bgm_sound_player: ShinobuSoundPlayer
var seconds_per_tick: float = 60000 / (BPM * GlobalSettings.PPQ) / 1000

var offset_ticks: float = -1 * (first_beat_offset_ms / 1000.0) / seconds_per_tick
var ticks: float = offset_ticks

var stream: AudioStream

var is_finished: bool = false

func _init() -> void:
	Shinobu.desired_buffer_size_msec = 10
	if Shinobu.initialize() == OK:
		#print("Shinobu is initialized.")
		
		bgm_group = Shinobu.create_group("BGM", null)
		if bgm_group.connect_to_endpoint() == OK:
			print("Connected to endpoint.")


func _ready() -> void:
	GlobalSettings.BPM_CHANGED.connect(_on_bpm_changed)
	GlobalSettings.OFFSET_CHANGED.connect(_on_offset_changed)
	#init_conductor(sound_file)
	#play()


func _on_bpm_changed(_bpm: float) -> void:
	BPM = _bpm
	seconds_per_tick = 60000 / (BPM * GlobalSettings.PPQ) / 1000


# _offset is in seconds
func _on_offset_changed(_offset: float) -> void:
	first_beat_offset_ms = int(_offset * 1000) #+ int(((60.0 / bpm) * 4.0) * 1000)
	offset_ticks = -1 * (first_beat_offset_ms / 1000.0) / seconds_per_tick
	ticks = offset_ticks


func _set_seconds_per_tick(value: float) -> void:
	BPM = value
	
	seconds_per_tick = 60000 / (BPM * GlobalSettings.PPQ) / 1000


func _set_offset_ticks(value: int) -> void:
	first_beat_offset_ms = value
	
	offset_ticks = -1 * (first_beat_offset_ms / 1000.0) / seconds_per_tick
	ticks = offset_ticks


func _process(_delta: float) -> void:
	#print(Shinobu.get_dsp_time() / 1000.0)
	if not is_instance_valid(bgm_sound_player):
		return
	
	if not bgm_sound_player.is_playing():
		if bgm_sound_player.is_at_stream_end() and not is_finished:
			is_finished = true
			finished.emit()
			bgm_sound_player.stop()
			
			return
		
		return
	
	var time_in_sec: float = (bgm_sound_player.get_playback_position_msec() - Shinobu.get_actual_buffer_size())/ 1000.0
	
	ticks = time_in_sec / seconds_per_tick + offset_ticks


func init_conductor(file: String) -> void:
	if get_child_count() > 0:
		for child in get_children():
			child.queue_free()
	
	if is_instance_valid(bgm_sound_player):
		bgm_sound_player = null
	
	if bgm_group.connect_to_endpoint() == OK:
		
		var audio_file: FileAccess = FileAccess.open(file, FileAccess.READ)
		var err: Error = FileAccess.get_open_error()
		
		if err == OK:
		
			sound_file = file
			
			var audio_byte_array: PackedByteArray = audio_file.get_buffer(audio_file.get_length())
			audio_file.close()
			
			var bgm_sound_source: ShinobuSoundSource = Shinobu.register_sound_from_memory("GameAudio", audio_byte_array)
			#print("Created ShinobuSoundSource")
			
			bgm_sound_player = bgm_sound_source.instantiate(bgm_group)
			#print("Created ShinobuSoundPlayer")
			add_child(bgm_sound_player)
		else:
			print("Shinobu error opening sound file %s" % err)


func get_current_beat() -> float:
	return floor(ticks / GlobalSettings.PPQ) + 1


func get_current_tick() -> float:
	return ticks


func get_length() -> float:
	if is_instance_valid(bgm_sound_player):
		return bgm_sound_player.get_length_msec() / 1000.0
	else:
		return 0.0


func get_song_time() -> float:
	return bgm_sound_player.get_playback_position_msec() / 1000.0


func get_playback_position() -> float:
	if is_instance_valid(bgm_sound_player):
		return bgm_sound_player.get_playback_position_msec() / 1000.0
	else:
		return 0.0


func get_ppq_duration() -> float:
	return 60000 / (BPM * GlobalSettings.PPQ) / 1000


func get_tick() -> float:
	return ticks


func is_at_end() -> void:
	if bgm_sound_player.is_at_stream_end():
		print("Finished")
		
		finished.emit()
		bgm_sound_player.stop()


func is_empty() -> bool:
	if is_instance_valid(bgm_sound_player):
		return bgm_sound_player.get_length_msec() <= 0
	else:
		return false


func is_playing() -> bool:
	if is_instance_valid(bgm_sound_player):
		return bgm_sound_player.is_playing()
	else:
		return false


func load_stream(new_stream: String) -> void:
	stream = Utils.create_audio_stream(new_stream)
	
	init_conductor(new_stream)
	loaded_new_stream.emit()


func pause() -> void:
	Shinobu.pause()
	bgm_sound_player.stop()


func unpause() -> void:
	Shinobu.resume()
	bgm_sound_player.start()


func play(_to_time_msec: int=0) -> void:
	Shinobu.resume()
	
	bgm_sound_player.seek(_to_time_msec)
	bgm_sound_player.start()


func stop() -> void:
	bgm_sound_player.stop()
