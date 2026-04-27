extends BaseUIScreen


@export_file var main_menu_path: String
@export var user_config: UserConfig
@export var sfx_player: AudioStreamPlayer
@export var animation_player: AnimationPlayer

@export_category("Volume Sliders")
@export var master_volume: HSlider
@export var music_volume: HSlider
@export var sfx_volume: HSlider

var _last_sfx_value: float = 1.0


func _ready() -> void:
	super._ready()
	
	title = "Settings"
	state = MainUIScreen.UI_Screens.SETTINGS
	
	animation_player.play("appear")
	
	await animation_player.animation_finished


func _on_back_button_pressed() -> void:
	if not UserConfig.is_video_pref_applied:
		GUI.set_resolution()
		GUI.set_window_mode()
	#elif UserConfig.is_audio_pref_applied or UserConfig.is_video_pref_applied:
	
	user_config.save_config()
	
	animation_player.play("disappear")
	
	await animation_player.animation_finished
	
	CHANGING_SCENE.emit(Vector2.ZERO, "", MainUIScreen.UI_Screens.MAIN_MENU)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	var snapped_value: float = snappedf(value, 0.1)
	
	if _last_sfx_value != snapped_value:
		_last_sfx_value = snapped_value
		
		sfx_player.play()


func _on_resolution_aspect_ratio_changed(aspect_ratio: float) -> void:
	gui_aspect_ratio = aspect_ratio
	GUIUtils.update_container.call_deferred(panel, arc, gui_aspect_ratio, gui_margin)


func change_scene() -> void:
	Loader.load_scene(self, main_menu_path, get_parent())
