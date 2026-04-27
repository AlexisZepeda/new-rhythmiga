extends Control

@export_file("*tscn") var main_ui_path: String
@export var user_config: UserConfig
@export var header: HeaderPrefab
@export var music_player_panel: MusicPlayerPanel

var scale_factor := 1.0
var gui_aspect_ratio := -1.0
var gui_margin := 0.0

@onready var panel: Panel = $Panel
@onready var arc: AspectRatioContainer = $Panel/AspectRatioContainer


func _init() -> void:
	MenuMusicPlayer.song_played.connect(_on_song_played)
	UserData.load_data()


func _ready() -> void:
	MenuMusicPlayer.init_menu_music_player()
	user_config.load_config()

	# The `resized` signal will be emitted when the window size changes, as the root Control node
	# is resized whenever the window size changes. This is because the root Control node
	# uses a Full Rect anchor, so its size will always be equal to the window size.
	gui_aspect_ratio = GUI.get_aspect_ratio()
	
	resized.connect(_on_resized)
	GUIUtils.update_container.call_deferred(panel, arc, gui_aspect_ratio, gui_margin)
	
	header.appear_anim()


func _on_resized() -> void:
	GUIUtils.update_container.call_deferred(panel, arc, gui_aspect_ratio, gui_margin)


func _on_song_played(song_key: String) -> void:
	var song_name: String = CustomMusicManager.get_song_name(song_key)
	var artist_name: String = CustomMusicManager.get_artist_name(song_key)
	
	music_player_panel.set_info(song_name, artist_name)
	
	music_player_panel.play_animations()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventKey:
		if event.is_pressed():
			
			await header.disappear_anim()
			
			Loader.load_scene(self, main_ui_path, get_tree().root)
