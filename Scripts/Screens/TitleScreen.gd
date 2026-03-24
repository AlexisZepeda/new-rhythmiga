extends Control

@export_file("*tscn") var main_ui_path: String
@export var user_config: UserConfig
@export var header: HeaderPrefab

var scale_factor := 1.0
var gui_aspect_ratio := -1.0
var gui_margin := 0.0

@onready var panel: Panel = $Panel
@onready var arc: AspectRatioContainer = $Panel/AspectRatioContainer


func _ready() -> void:
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


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventKey:
		if event.is_pressed():
			
			await header.disappear_anim()
			
			Loader.load_scene(self, main_ui_path)
