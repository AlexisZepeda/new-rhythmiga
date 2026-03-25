extends Control

signal CHANGING_SCENE(header_position: Vector2, new_title: String)

@export_file_path var main_menu_path: String
@export var title: String = "Editor"

@export var back_button: Button

var scale_factor := 1.0
var gui_aspect_ratio := -1.0
var gui_margin := 0.0

@onready var panel: Panel = $Panel
@onready var arc: AspectRatioContainer = $Panel/AspectRatioContainer


func _ready() -> void:
	gui_aspect_ratio = GUI.get_aspect_ratio()
	resized.connect(_on_resized)
	GUIUtils.update_container.call_deferred(panel, arc, gui_aspect_ratio, gui_margin)
	
	back_button.pressed.connect(_on_back_pressed)


func _on_resized() -> void:
	GUIUtils.update_container.call_deferred(panel, arc, gui_aspect_ratio, gui_margin)


func _on_back_pressed() -> void:
	CHANGING_SCENE.emit(Vector2.ZERO, "")


func change_scene() -> void:
	Loader.load_scene(self, main_menu_path, get_parent())
