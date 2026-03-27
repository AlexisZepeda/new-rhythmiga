class_name BaseUIScreen
extends Control

signal CHANGING_SCENE(header_position: Vector2, new_title: String, _state: MainUIScreen.UI_Screens)
@export var title: String = "Base UI"

var state: MainUIScreen.UI_Screens = MainUIScreen.UI_Screens.NONE

var scene_path: String

var scale_factor := 1.0
var gui_aspect_ratio:float = -1.0
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


func change_scene() -> void:
	Loader.load_scene(self, scene_path, get_parent())
