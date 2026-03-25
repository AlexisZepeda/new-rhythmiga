extends Control

signal CHANGING_SCENE(header_position: Vector2, new_title: String)

@export_file var main_menu_path: String
@export var title: String = "Settings"
@export var user_config: UserConfig
@export var sfx_player: AudioStreamPlayer

@export_category("Volume Sliders")
@export var master_volume: HSlider
@export var music_volume: HSlider
@export var sfx_volume: HSlider

var _last_sfx_value: float = 1.0

var scale_factor := 1.0
var gui_aspect_ratio := -1.0
var gui_margin := 0.0

@onready var panel: Panel = $Panel
@onready var arc: AspectRatioContainer = $Panel/AspectRatioContainer


func _ready() -> void:
	# The `resized` signal will be emitted when the window size changes, as the root Control node
	# is resized whenever the window size changes. This is because the root Control node
	# uses a Full Rect anchor, so its size will always be equal to the window size.
	gui_aspect_ratio = GUI.get_aspect_ratio()
	resized.connect(_on_resized)
	GUIUtils.update_container.call_deferred(panel, arc, gui_aspect_ratio, gui_margin)


func _on_resized() -> void:
	GUIUtils.update_container.call_deferred(panel, arc, gui_aspect_ratio, gui_margin)


func _on_back_button_pressed() -> void:
	if not UserConfig.is_video_pref_applied:
		GUI.set_resolution()
		GUI.set_window_mode()
	#elif UserConfig.is_audio_pref_applied or UserConfig.is_video_pref_applied:
	
	user_config.save_config()
	
	CHANGING_SCENE.emit(Vector2.ZERO, "")


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
