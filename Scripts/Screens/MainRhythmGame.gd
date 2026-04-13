class_name MainRhythmGame
extends BaseUIScreen

@export_file_path var result_screen_path: String
@export_file_path var song_list_screen_path: String

@export var conductor: ChartConductor
@export var rhythm_game: RhythmGame
@export var pause_container: MarginContainer
@export var retry_btn: Button
@export var song_list_btn: Button


func _ready() -> void:
	state = MainUIScreen.UI_Screens.RHYTHM_GAME
	_connect_signals()
	
	EmbeddedGlobalSettings.enable_input = true
	conductor.load_stream(Loader.loaded_stream)
	
	rhythm_game.init_rhythm_game(RhythmGame.Game_Version.MAIN_GAME)
	rhythm_game.init_beatmap(Loader.beat_map_path)


func _connect_signals() -> void:
	rhythm_game.game_finished.connect(_on_game_finished)
	retry_btn.pressed.connect(_on_retry_pressed)
	song_list_btn.pressed.connect(_on_song_list_pressed)


func _on_game_finished() -> void:
	EmbeddedGlobalSettings.current_game_stats = rhythm_game.play_stats
	
	CHANGING_SCENE.emit(Vector2.ZERO, "", MainUIScreen.UI_Screens.RESULT_SCREEN)
	scene_path = result_screen_path


func _on_retry_pressed() -> void:
	get_tree().paused = false
	
	await get_tree().process_frame
	
	get_tree().reload_current_scene()


func _on_song_list_pressed() -> void:
	GlobalBackground.appear_shader()
	CHANGING_SCENE.emit(Vector2.ZERO, "", MainUIScreen.UI_Screens.SONG_LIST)
	scene_path = song_list_screen_path


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if pause_container.visible:
			unpause()
		else:
			pause()


func change_scene() -> void:
	get_tree().paused = false
	Loader.load_scene(self, scene_path, get_parent())


func pause() -> void:
	pause_container.show()
	get_tree().paused = true
	conductor.pause_conductor()


func unpause() -> void:
	pause_container.hide()
	get_tree().paused = false
	
	await get_tree().create_timer(2.0).timeout
	
	conductor.unpause_conductor()
