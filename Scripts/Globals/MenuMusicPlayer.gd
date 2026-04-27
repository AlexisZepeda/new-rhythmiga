extends Node

signal song_played(song_key: String)


@export var audio_stream_player: AudioStreamPlayer

var playlist: Array = []
## Points to the position in the [member playlist].
var current_song_ptr: int = -1
## Points to the actual value in the [member playlist].
var current_song_index: int = -1

var song_position_sec: float = 0.0


func _init() -> void:
	CustomMusicManager.load_custom_music_directory()
	
	_create_playlist()
	_update_current_song_ptr()


func _ready() -> void:
	audio_stream_player.finished.connect(_on_finished)


func _create_playlist() -> void:
	var size: int = CustomMusicManager.get_library_size()
	
	for i: int in range(size):
		playlist.append(i)
	
	playlist.shuffle()


func _get_playlist_index() -> int:
	return playlist[current_song_ptr]


func _on_finished() -> void:
	# Move on to next song in playlist
	next_song()


#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed == true:
			#next_song()


## Increments the [member current_song_ptr] by one and re-shuffles the [member playlist]
## if the [member current_song_prt] has reached the end.
func _update_current_song_ptr() -> void:
	current_song_ptr += 1
	
	if current_song_ptr > (playlist.size() - 1):
		playlist.shuffle()
		
		current_song_ptr = 0
	
	current_song_index = _get_playlist_index()


func init_menu_music_player() -> void:
	load_song()


func load_song() -> void:
	var song_key: String = CustomMusicManager.get_song_key(current_song_index)
	var song_path: String = CustomMusicManager.get_song_path_on_key(song_key)
	
	var audio_stream: AudioStream = CustomMusicManager.load_audio_on_path(song_path)
	
	audio_stream_player.stream = audio_stream
	
	song_played.emit(song_key)
	audio_stream_player.play()


func lower_volume() -> void:
	var vol_tween: Tween = create_tween()
	vol_tween.tween_property(audio_stream_player, "volume_linear", 0.0, 1.0)
	
	await vol_tween.finished
	
	stop_song()


func next_song() -> void:
	_update_current_song_ptr()
	load_song()


func play_song() -> void:
	audio_stream_player.play(song_position_sec)


func stop_song() -> void:
	song_position_sec = audio_stream_player.get_playback_position()
	audio_stream_player.stop()
