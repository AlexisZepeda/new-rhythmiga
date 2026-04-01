class_name MainRhythmGame
extends BaseUIScreen

@export var conductor: ChartConductor
@export var rhythm_game: RhythmGame


func _ready() -> void:
	state = MainUIScreen.UI_Screens.RHYTHM_GAME
	
	EmbeddedGlobalSettings.enable_input = true
	rhythm_game.state = RhythmGame.Game_Version.MAIN_GAME
	conductor.load_stream(Loader.loaded_stream)
	
	rhythm_game.init_beatmap(Loader.beat_map_path)
