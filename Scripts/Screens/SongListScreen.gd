extends Control

signal CHANGING_SCENE(header_position: Vector2, new_title: String)

@export_file_path var main_menu_path: String
@export var title: String = "Song List"

@export var song_button_prefab: PackedScene
@export var back_button: Button
@export var song_button_list: VBoxContainer
@export var song_info_container: SongInfoContainer
@export var player: AudioStreamPlayer

var scale_factor := 1.0
var gui_aspect_ratio := -1.0
var gui_margin := 0.0

@onready var panel: Panel = $Panel
@onready var arc: AspectRatioContainer = $Panel/AspectRatioContainer
@onready var margin: MarginContainer = $"Panel/AspectRatioContainer/Panel/MarginContainer"


func _ready() -> void:
	gui_aspect_ratio = GUI.get_aspect_ratio()
	resized.connect(_on_resized)
	GUIUtils.update_container.call_deferred(panel, arc, gui_aspect_ratio, gui_margin)
	GUIUtils.update_margin_container.call_deferred(margin, 67)
	
	back_button.pressed.connect(_on_back_pressed)
	
	load_songs()


func _on_resized() -> void:
	GUIUtils.update_container.call_deferred(panel, arc, gui_aspect_ratio, gui_margin)


func _on_back_pressed() -> void:
	CHANGING_SCENE.emit(Vector2.ZERO, "")


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
	song_info_container.set_info(btn.song_title_str, btn.artist_str, btn.score_str, btn.cover_art_texture)
	
	player.stream = btn.audio_stream
	
	player.play()


func load_songs() -> void:
	for key: String in CustomMusicManager.library:
		var song_name: String = CustomMusicManager.library[key][CustomMusicManager.Library_Keys.SONG_NAME]
		if song_name != "":
			var btn: NewSongButton = song_button_prefab.instantiate()
			btn.audio_stream = CustomMusicManager.load_audio(song_name)
			btn.set_song_title(song_name)
			btn.id = song_name
			
			var entered = Callable(self, "_on_mouse_entered").bind(btn)
			btn.mouse_entered.connect(entered)
			
			
			song_button_list.add_child(btn)


func change_scene() -> void:
	Loader.load_scene(self, main_menu_path, get_parent())
