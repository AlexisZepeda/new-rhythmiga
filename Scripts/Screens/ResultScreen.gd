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

@export var grid_container: GridContainer
@export var song_panel: SongPanel
@export var button_vbox: VBoxContainer
@export var inner_panel: Panel
@export var main_vbox: VBoxContainer

var all_labels: Array[Node]

@onready var margin: MarginContainer = $"Panel/AspectRatioContainer/Panel/MarginContainer"


func _ready() -> void:
	super._ready()
	
	state = MainUIScreen.UI_Screens.RESULT_SCREEN
	
	MenuMusicPlayer.is_playing_song()
	
	GUIUtils.update_margin_container.call_deferred(margin, GUIUtils.GUI_MARGIN)
	
	GlobalBackground.appear_shader()
	
	_connect_signals()
	song_panel.set_info()
	
	await get_tree().process_frame
	
	all_labels = grid_container.get_children()
	all_labels.sort_custom(GUIUtils.buttons_array_sorting)
	
	await animate_label(all_labels.duplicate(), true, 0.25, Vector2(-10, 0), Vector2.ZERO, 0.75)
	
	set_scores()
	save_score()


func _connect_signals() -> void:
	main_menu_btn.connect_signals()
	song_list_btn.connect_signals()
	retry_btn.connect_signals()
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	song_list_btn.pressed.connect(_on_song_list_pressed)
	retry_btn.pressed.connect(_on_retry_pressed)


func _on_main_menu_pressed() -> void:
	var button_position: Vector2 = main_menu_btn.position + button_vbox.position + inner_panel.position + main_vbox.position
	
	CHANGING_SCENE.emit(button_position, "Main Menu", main_menu_btn.screen)
	scene_path = main_menu_screen_path
	
	disconnect_buttons()


func _on_song_list_pressed() -> void:
	var button_position: Vector2 = song_list_btn.position + button_vbox.position + inner_panel.position + main_vbox.position
	
	CHANGING_SCENE.emit(button_position, "Quickplay", song_list_btn.screen)
	scene_path = song_list_screen_path
	
	MenuMusicPlayer.lower_volume()
	
	disconnect_buttons()


func _on_retry_pressed() -> void:
	GlobalBackground.disappear_shader()
	CHANGING_SCENE.emit(Vector2.ZERO, "", retry_btn.screen)
	scene_path = main_rhythm_game_path
	
	MenuMusicPlayer.lower_volume()
	
	disconnect_buttons()


func animate_label(labels: Array, forward: bool=true, delay_between_labels: float=0.16, move_offset: Vector2=Vector2(-20, 0), scale_offset: Vector2=Vector2.ZERO, animation_length:float=0.52) -> void:
	if not forward:
		labels.reverse()
	
	for label: Label in labels:
		#if label is not ScoreLabel:
			#continue
		
		if forward:
			label.modulate.a = 0.0
		else: 
			label.modulate.a = 1.0
		
		label.pivot_offset.y = label.size.y / 2.0
		
		if forward:
			label.scale = scale_offset
		else:
			label.scale = Vector2.ONE
	
	for label: Label in labels:
		#if label is not ScoreLabel:
			#continue
		
		var tween_ease: int = Tween.EASE_OUT if forward else Tween.EASE_IN
		var pos_tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(tween_ease)
		var mod_tween: Tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(tween_ease)
		var scale_tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(tween_ease)
		
		var target_pos: Vector2 = label.position - move_offset if forward else label.position + move_offset
		var target_mod: float = 1.0 if forward else 0.0
		var target_scale: Vector2 = Vector2.ONE if forward else scale_offset
		
		pos_tween.tween_property(label, "position", target_pos, animation_length)
		mod_tween.tween_property(label, "modulate:a", target_mod, animation_length)
		scale_tween.tween_property(label, "scale", target_scale, animation_length)
		
		#pos_tween.chain().tween_property(label, "position:x", label.original_position.x, animation_length).set_trans(Tween.TRANS_SINE)
		
		await get_tree().create_timer(delay_between_labels).timeout


func change_scene() -> void:
	Loader.load_scene(self, scene_path, get_parent())


func disconnect_buttons() -> void:
	main_menu_btn.disconnect_signals()
	song_list_btn.disconnect_signals()
	retry_btn.disconnect_signals()


func save_score() -> void:
	UserData.save_score(current_game_stats.target_score, CustomMusicManager.current_difficulty)


func set_scores() -> void:
	await score.set_score(current_game_stats.target_score)
	await perfect.set_score(current_game_stats.perfect_count)
	await critical.set_score(current_game_stats.critical_count)
	await great.set_score(current_game_stats.great_count)
	await good.set_score(current_game_stats.good_count)
	await bad.set_score(current_game_stats.bad_count)
	await miss.set_score(current_game_stats.miss_count)
