extends BaseUIScreen

@export_file_path var main_menu_path: String

@export var song_button_prefab: PackedScene
@export var back_button: Button
@export var song_button_list: VBoxContainer
@export var song_info_container: SongInfoContainer
@export var player: AudioStreamPlayer


@onready var margin: MarginContainer = $"Panel/AspectRatioContainer/Panel/MarginContainer"


func _ready() -> void:
	super._ready()
	GUIUtils.update_margin_container.call_deferred(margin, 67)
	CustomMusicManager.load_custom_music_directory()
	
	title = "Song List"
	state = MainUIScreen.UI_Screens.SONG_LIST
	
	back_button.pressed.connect(_on_back_pressed)
	
	load_songs()


func _on_back_pressed() -> void:
	CHANGING_SCENE.emit(Vector2.ZERO, "", MainUIScreen.UI_Screens.MAIN_MENU)


func _on_mouse_entered(btn: NewSongButton) -> void:
	#if stream.tags.has("metadata_block_picture"):
		#var data: PackedByteArray = Marshalls.base64_to_raw(stream.tags["metadata_block_picture"])
		#
		#print("First 16 bytes (hex) %s" % [data.slice(0, 4).hex_encode()])
		#var streambuffer: StreamPeerBuffer = StreamPeerBuffer.new()
		#streambuffer.big_endian = true
		#streambuffer.data_array = data.slice(0, 4)
		#var text = streambuffer.get_u32()
		#
		#streambuffer.data_array = data.slice(4, 8)
		#
		#print("Text Preview")
		#print(text)
	print(btn.song_title_str)
	song_info_container.set_info(btn.song_title_str, btn.artist_str, btn.score_str, btn.cover_art.texture)
	
	player.stream = btn.audio_stream
	
	player.play()


func load_songs() -> void:
	for key: String in CustomMusicManager.library:
		var song_name: String = CustomMusicManager.library[key][CustomMusicManager.Library_Keys.SONG_NAME]
		var artist: String = CustomMusicManager.library[key][CustomMusicManager.Library_Keys.ARTIST]
		var cover_path: String = CustomMusicManager.library[key][CustomMusicManager.Library_Keys.COVER_PATH]
		
		
		if song_name != "":
			var btn: NewSongButton = song_button_prefab.instantiate()
			btn.audio_stream = CustomMusicManager.load_audio(song_name)
			btn.set_song_title(song_name)
			btn.set_artist(artist)
			btn.set_cover_art(cover_path)
			btn.id = song_name
			
			var entered = Callable(self, "_on_mouse_entered").bind(btn)
			btn.mouse_entered.connect(entered)
			
			
			song_button_list.add_child(btn)


func change_scene() -> void:
	Loader.load_scene(self, main_menu_path, get_parent())
