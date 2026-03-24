extends Control

@export_category("Screens")
@export_file_path("*tscn") var main_menu_screen: String
@export_file_path("*tscn") var settings_menu_screen: String
@export_category("")

@export var header: HeaderPrefab

var panel: PanelContainer
var first_scene_loaded: bool = true


func _ready() -> void:
	Loader.LOADED_SCENE.connect(_on_loaded_scene)
	
	panel = PanelContainer.new()
	add_child(panel)
	
	await get_tree().process_frame
	
	Loader.load_scene(panel, main_menu_screen)


func _on_loaded_scene(node: Node) -> void:
	
	if node != self:
		node.CHANGING_SCENE.connect(_on_changing_scene)
		
		header.set_label_text(node.title)
		
		if first_scene_loaded:
			header.enter_anim(Vector2(100, 0))
			first_scene_loaded = false


func _on_changing_scene(new_position: Vector2) -> void:
	var prev_position: Vector2 = header.position
	
	await header.disappear_anim()
	
	header.position = new_position
	
	var tween: Tween = create_tween()
	tween.tween_property(header, "position", prev_position, 0.5)
