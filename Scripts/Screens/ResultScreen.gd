class_name ResultScreen
extends BaseUIScreen

@export_file_path var main_menu_screen_path: String
@export_file_path var song_list_screen_path: String
@export_file_path var main_rhythm_game_path: String

@export var current_game_stats: CurrentGameStats

@export_category("UI")
@export_group("Scores")
@export var score: Label
@export var perfect: Label
@export var critical: Label
@export var great: Label
@export var good: Label
@export var bad: Label
@export var miss: Label
@export_group("")

@export_group("Buttons")
@export var main_menu_btn: Button
@export var song_list_btn: Button
@export var retry_btn: Button
@export_group("")

@onready var margin: MarginContainer = $"Panel/AspectRatioContainer/Panel/MarginContainer"


func _ready() -> void:
	state = MainUIScreen.UI_Screens.RESULT_SCREEN
	GUIUtils.update_margin_container.call_deferred(margin, 67)
	
	await GlobalBackground.appear_shader()
	
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	song_list_btn.pressed.connect(_on_song_list_pressed)
	retry_btn.pressed.connect(_on_retry_pressed)
	
	set_scores()
	save_score()

func _on_main_menu_pressed() -> void:
	CHANGING_SCENE.emit(Vector2.ZERO, "", MainUIScreen.UI_Screens.MAIN_MENU)
	scene_path = main_menu_screen_path


func _on_song_list_pressed() -> void:
	CHANGING_SCENE.emit(Vector2.ZERO, "", MainUIScreen.UI_Screens.SONG_LIST)
	scene_path = song_list_screen_path


func _on_retry_pressed() -> void:
	GlobalBackground.disappear_shader()
	CHANGING_SCENE.emit(Vector2.ZERO, "", MainUIScreen.UI_Screens.RHYTHM_GAME)
	scene_path = main_rhythm_game_path


func change_scene() -> void:
	Loader.load_scene(self, scene_path, get_parent())


func save_score() -> void:
	UserData.save_score(current_game_stats.target_score, CustomMusicManager.current_difficulty)


func set_scores() -> void:
	await score.set_score(str(current_game_stats.target_score))
	await perfect.set_score(str(current_game_stats.perfect_count))
	await critical.set_score(str(current_game_stats.critical_count))
	await great.set_score(str(current_game_stats.great_count))
	await good.set_score(str(current_game_stats.good_count))
	await bad.set_score(str(current_game_stats.bad_count))
	await miss.set_score(str(current_game_stats.miss_count))
