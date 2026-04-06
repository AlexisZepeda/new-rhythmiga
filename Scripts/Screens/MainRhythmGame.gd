class_name MainRhythmGame
extends BaseUIScreen

@export_file_path var result_screen_path: String

@export var conductor: ChartConductor
@export var rhythm_game: RhythmGame
@export var pause_container: MarginContainer


func _ready() -> void:
	state = MainUIScreen.UI_Screens.RHYTHM_GAME
	conductor.finished.connect(_on_conductor_finished)
	
	EmbeddedGlobalSettings.enable_input = true
	rhythm_game.state = RhythmGame.Game_Version.MAIN_GAME
	conductor.load_stream(Loader.loaded_stream)
	
	rhythm_game.init_beatmap(Loader.beat_map_path)


func _on_conductor_finished() -> void:
	EmbeddedGlobalSettings.current_game_stats = rhythm_game.play_stats
	
	CHANGING_SCENE.emit(Vector2.ZERO, "", MainUIScreen.UI_Screens.RESULT_SCREEN)
	scene_path = result_screen_path
	
	await get_tree().create_timer(2.0).timeout


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if pause_container.visible:
			unpause()
		else:
			pause()


func change_scene() -> void:
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
