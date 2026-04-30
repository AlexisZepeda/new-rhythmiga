class_name MainRhythmGame
extends BaseUIScreen

@export_file_path var result_screen_path: String
@export_file_path var song_list_screen_path: String

#@export var conductor: ChartConductor
@export var shinobu_conductor: ShinobuConductor
@export var rhythm_game: RhythmGame
@export var pause_container: MarginContainer
@export var button_vbox: VBoxContainer
@export var countdown_timer: Countdown

@export_group("Buttons")
@export var continue_btn: Button
@export var retry_btn: Button
@export var song_list_btn: Button
@export_group("")

var can_pause: bool = false


func _ready() -> void:
	state = MainUIScreen.UI_Screens.RHYTHM_GAME
	_connect_signals()
	
	can_pause = false
	EmbeddedGlobalSettings.enable_input = true
	#conductor.load_stream(Loader.loaded_stream)
	shinobu_conductor.load_stream(Loader.loaded_music_path)
	
	rhythm_game.init_rhythm_game(RhythmGame.Game_Version.MAIN_GAME)
	rhythm_game.init_beatmap(Loader.beat_map_path)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _connect_signals() -> void:
	rhythm_game.game_start.connect(_on_game_start)
	rhythm_game.game_finished.connect(_on_game_finished)
	continue_btn.pressed.connect(_on_continue_pressed)
	retry_btn.pressed.connect(_on_retry_pressed)
	song_list_btn.pressed.connect(_on_song_list_pressed)
	countdown_timer.finished.connect(_on_countdown_finished)


func _on_continue_pressed() -> void:
	button_vbox.hide()
	countdown_timer.show()
	countdown_timer.start()


func _on_countdown_finished() -> void:
	unpause()


func _on_game_finished() -> void:
	EmbeddedGlobalSettings.current_game_stats = rhythm_game.play_stats
	
	CHANGING_SCENE.emit(Vector2.ZERO, "", MainUIScreen.UI_Screens.RESULT_SCREEN)
	scene_path = result_screen_path


func _on_game_start() -> void:
	can_pause = true


func _on_retry_pressed() -> void:
	get_tree().paused = false
	
	await get_tree().process_frame
	
	get_tree().reload_current_scene()


func _on_song_list_pressed() -> void:
	GlobalBackground.appear_shader()
	CHANGING_SCENE.emit(Vector2.ZERO, "", MainUIScreen.UI_Screens.SONG_LIST)
	scene_path = song_list_screen_path


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and can_pause:
		if pause_container.visible:
			unpause()
		else:
			pause()


func change_scene() -> void:
	get_tree().paused = false
	Loader.load_scene(self, scene_path, get_parent())


func pause() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pause_container.show()
	button_vbox.show()
	get_tree().paused = true
	shinobu_conductor.pause()


func unpause() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pause_container.hide()
	countdown_timer.hide()
	get_tree().paused = false
	
	shinobu_conductor.unpause()
