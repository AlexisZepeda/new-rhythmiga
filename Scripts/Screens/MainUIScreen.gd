class_name MainUIScreen
extends Control

@export_category("Screens")
@export_file_path("*tscn") var main_menu_screen: String
@export_file_path("*tscn") var settings_menu_screen: String
@export_category("")

@export var header: HeaderPrefab
@export var header_prefab: PackedScene

# Changing the order of values will require reloading the project.
# Components which export UI_Screens need to update.
enum UI_Screens {
	MAIN_MENU,
	SONG_LIST,
	CHART_EDITOR,
	SETTINGS,
	RHYTHM_GAME,
	RESULT_SCREEN,
	NONE,
}

var panel: PanelContainer
var first_scene_loaded: bool = true

var child_scene: BaseUIScreen
var state: UI_Screens


func _ready() -> void:
	Loader.LOADED_SCENE.connect(_on_loaded_scene)
	
	header.visible = false
	
	panel = PanelContainer.new()
	add_child(panel)
	
	await get_tree().process_frame
	
	if Loader.scene_path.is_empty():
		Loader.load_scene(panel, main_menu_screen, self)
	else:
		Loader.load_scene(panel, Loader.scene_path, self)


func _on_loaded_scene(node: Node) -> void:
	if node != self:
		child_scene = node
		
		node.CHANGING_SCENE.connect(_on_changing_scene)
		
		state = child_scene.state
		
		match state:
			UI_Screens.CHART_EDITOR, UI_Screens.RHYTHM_GAME:
				header.visible = false
			_:
				header.visible = true
		
		header.set_label_text(node.title)
		
		if first_scene_loaded:
			
			header.enter_anim(Vector2(100, 0))
			first_scene_loaded = false


func _on_changing_scene(new_position: Vector2, title: String, incoming_state: UI_Screens) -> void:
	var prev_position: Vector2 = header.position + Vector2(100.0, 0.0)
	
	await header.disappear_anim()
	
	header.queue_free()
	
	await header.tree_exited
	
	header = header_prefab.instantiate()
	add_child(header)
	
	header.set_label_text(title)
	header.position = new_position
	
	match incoming_state:
		UI_Screens.CHART_EDITOR, UI_Screens.RHYTHM_GAME:
			header.visible = false
		_:
			if new_position == Vector2.ZERO:
				first_scene_loaded = true
			else:
				await header.move_anim(prev_position)
	
	child_scene.change_scene()
