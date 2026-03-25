extends Control

signal CHANGING_SCENE(header_position: Vector2, new_title: String)

@export_file_path var settings_menu_path: String
@export_file_path var song_list_menu_path: String
@export_file_path var chart_editor_menu_path: String
@export var title: String = "Main Menu"

@export var button_vbox: VBoxContainer

var scale_factor := 1.0
var gui_aspect_ratio:float = -1.0
var gui_margin := 0.0

var all_buttons: Array

var scene_path: String

@onready var panel: Panel = $Panel
@onready var arc: AspectRatioContainer = $Panel/AspectRatioContainer

func _ready() -> void:
	# The `resized` signal will be emitted when the window size changes, as the root Control node
	# is resized whenever the window size changes. This is because the root Control node
	# uses a Full Rect anchor, so its size will always be equal to the window size.
	gui_aspect_ratio = GUI.get_aspect_ratio()
	resized.connect(_on_resized)
	GUIUtils.update_container.call_deferred(panel, arc, gui_aspect_ratio, gui_margin)
	
	
	all_buttons = GUIUtils.get_all_buttons(button_vbox)
	
	for btn: MenuButtonPrefab in all_buttons:
		var pressed = Callable(self, "_on_pressed").bind(btn)
		btn.pressed.connect(pressed)
	
	await get_tree().process_frame
	
	all_buttons.sort_custom(GUIUtils.buttons_array_sorting)
	await animate_buttons(all_buttons.duplicate(), true, 0.50, Vector2(-10, 0), Vector2.ZERO, 0.75)
	
	for btn: MenuButtonPrefab in all_buttons:
		btn.connect_signals()


func _on_resized() -> void:
	GUIUtils.update_container.call_deferred(panel, arc, gui_aspect_ratio, gui_margin)


func _on_pressed(button: MenuButtonPrefab) -> void:
	var button_position: Vector2 = button.position + button_vbox.position + arc.position
	
	match button.screen:
		MainUIScreen.UI_Screens.SONG_LIST:
			CHANGING_SCENE.emit(button_position, "Song List")
			scene_path = song_list_menu_path
		MainUIScreen.UI_Screens.CHART_EDITOR:
			CHANGING_SCENE.emit(button_position, "Editor")
			scene_path = chart_editor_menu_path
		MainUIScreen.UI_Screens.SETTINGS:
			CHANGING_SCENE.emit(button_position, "Settings")
			scene_path = settings_menu_path


func animate_buttons(buttons: Array, forward: bool=true, delay_between_buttons: float=0.16, move_offset: Vector2=Vector2(-20, 0), scale_offset: Vector2=Vector2.ZERO, animation_length:float=0.52) -> void:
	if not forward:
		buttons.reverse()
	
	for btn: Button in buttons:
		if forward:
			btn.modulate.a = 0.0
		else: 
			btn.modulate.a = 1.0
		
		btn.pivot_offset.y = btn.size.y / 2.0
		
		if forward:
			btn.scale = scale_offset
		else:
			btn.scale = Vector2.ONE
	
	for btn: Button in buttons:
		var tween_ease: int = Tween.EASE_OUT if forward else Tween.EASE_IN
		var pos_tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(tween_ease)
		var mod_tween: Tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(tween_ease)
		var scale_tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(tween_ease)
		
		var target_pos: Vector2 = btn.position - move_offset if forward else btn.position + move_offset
		var target_mod: float = 1.0 if forward else 0.0
		var target_scale: Vector2 = Vector2.ONE if forward else scale_offset
		
		pos_tween.tween_property(btn, "position", target_pos, animation_length)
		mod_tween.tween_property(btn, "modulate:a", target_mod, animation_length)
		scale_tween.tween_property(btn, "scale", target_scale, animation_length)
		
		pos_tween.chain().tween_property(btn, "position:x", btn.original_position.x, animation_length).set_trans(Tween.TRANS_SINE)
		
		await get_tree().create_timer(delay_between_buttons).timeout


func change_scene() -> void:
	await animate_buttons(all_buttons, false, 0.50, Vector2(0, 0), Vector2.ONE, 0.50)
	
	Loader.load_scene(self, scene_path, get_parent())
