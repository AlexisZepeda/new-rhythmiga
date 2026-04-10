extends BaseUIScreen

@export_file_path var main_menu_path: String
@export_file_path var main_rhythm_game_path: String

@export var song_button_prefab: PackedScene
@export var back_button: Button
@export var play_button: Button
@export var song_button_list: VBoxContainer
@export var song_info_container: SongInfoContainer
@export var player: AudioStreamPlayer

var hovered_btn: NewSongButton

@onready var margin: MarginContainer = $"Panel/AspectRatioContainer/Panel/MarginContainer"


func _ready() -> void:
	super._ready()
	
	GUIUtils.update_margin_container.call_deferred(margin, 67)
	CustomMusicManager.load_custom_music_directory()
	
	title = "Song List"
	state = MainUIScreen.UI_Screens.SONG_LIST
	
	back_button.pressed.connect(_on_back_pressed)
	play_button.pressed.connect(_on_play_pressed)
	song_info_container.difficulty_changed.connect(_on_difficulty_changed)
	
	load_songs()
	
	_on_mouse_entered(song_button_list.get_children()[0])


func _on_back_pressed() -> void:
	disappear()
	
	CHANGING_SCENE.emit(Vector2.ZERO, "", MainUIScreen.UI_Screens.MAIN_MENU)
	scene_path = main_menu_path


func _on_difficulty_changed(difficulty: Enums.Difficulty) -> void:
	var score: int = UserData.get_score(hovered_btn.id, difficulty)
	song_info_container.set_score(score)
	set_all_button_score(difficulty)


func _on_play_pressed() -> void:
	disappear()
	
	CHANGING_SCENE.emit(Vector2.ZERO, "", MainUIScreen.UI_Screens.RHYTHM_GAME)
	scene_path = main_rhythm_game_path
	GlobalBackground.disappear_shader()
	Loader.loaded_stream = player.stream
	Loader.beat_map_path = CustomMusicManager.load_beat_map(hovered_btn.id, song_info_container.difficulty)


func _on_mouse_entered(btn: NewSongButton) -> void:
	hovered_btn = btn
	
	song_info_container.set_info(btn.song_title_str, btn.artist_str, btn.score_str, btn.cover_art.texture)
	song_info_container.enable_difficulties(hovered_btn.id)
	
	player.stream = btn.audio_stream
	
	player.play()



func load_songs() -> void:
	for key: String in CustomMusicManager.library:
		var song_name: String = CustomMusicManager.library[key][CustomMusicManager.Library_Keys.SONG_NAME]
		var artist: String = CustomMusicManager.library[key][CustomMusicManager.Library_Keys.ARTIST]
		var cover_path: String = CustomMusicManager.library[key][CustomMusicManager.Library_Keys.COVER_PATH]
		var score: int = UserData.get_score(key, CustomMusicManager.current_difficulty)
		
		if song_name != "":
			var btn: NewSongButton = song_button_prefab.instantiate()
			btn.audio_stream = CustomMusicManager.load_audio(song_name)
			btn.set_song_title(song_name)
			btn.set_artist(artist)
			btn.set_cover_art(cover_path)
			btn.set_score(score)
			btn.id = key
			
			var entered = Callable(self, "_on_mouse_entered").bind(btn)
			btn.button.mouse_entered.connect(entered)
			
			song_button_list.add_child(btn)


func disappear() -> void:
	song_info_container.disappear_anim()
	lower_volume()
	var buttons = song_button_list.get_children()
	
	for button: NewSongButton in buttons:
		await button.disappear_anim()


func change_scene() -> void:
	Loader.load_scene(self, scene_path, get_parent())


func set_all_button_score(difficulty: Enums.Difficulty) -> void:
	var buttons: Array = song_button_list.get_children()
	
	for button: NewSongButton in buttons:
		var score: int = UserData.get_score(button.id, difficulty)
		button.set_score(score)


func lower_volume() -> void:
	var vol_tween: Tween = create_tween()
	vol_tween.tween_property(player, "volume_linear", 0.0, 0.75)
