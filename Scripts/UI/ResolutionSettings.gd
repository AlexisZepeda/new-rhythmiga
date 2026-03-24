extends VBoxContainer

signal aspect_ratio_changed(aspect_ratio: float)

@export_category("Options")
@export var resolution_option_button: OptionButton
@export var windows_option_button: OptionButton
@export var aspect_ratio_button: OptionButton
@export_category("")

@export var apply: Button
@export var reset: Button

var resolution: GUI.Base_Resolutions
var window_mode: GUI.Window_Modes 
var gui_aspect_ratio: GUI.Aspect_Ratios


func _ready() -> void:
	apply.pressed.connect(_on_apply_pressed)
	reset.pressed.connect(_on_reset_pressed)
	
	add_resolutions()
	add_aspect_ratios()
	add_window_modes()
	
	print("Ready Video Settings Resolution %s" % GUI.current_resolution)
	resolution_option_button.select(GUI.current_resolution)
	windows_option_button.select(GUI.current_window_mode)
	aspect_ratio_button.select(GUI.current_gui_aspect_ratio)
	
	print(resolution_option_button.get_selected_id())

func _on_resolution_option_item_selected(index: int) -> void:
	resolution = index as GUI.Base_Resolutions
	GUI.set_resolution(index)


func _on_windows_option_item_selected(index: int) -> void:
	window_mode = windows_option_button.get_item_id(index) as GUI.Window_Modes
	GUI.set_window_mode(window_mode)
	
	if window_mode != GUI.Window_Modes.WINDOWED:
		disable_resolutions()
	else:
		enable_resolutions()


func _on_gui_aspect_ratio_item_selected(index: int) -> void:
	var _gui_aspect_ratio = GUI.get_aspect_ratio(index)
	gui_aspect_ratio = index as GUI.Aspect_Ratios
	#GUI.current_gui_aspect_ratio = index as GUI.Aspect_Ratios
	aspect_ratio_changed.emit(_gui_aspect_ratio)


func add_resolutions() -> void:
	for key in GUI.RESOLUTIONS:
		var _resolution: Vector2i = GUI.RESOLUTIONS[key]
		var label: String = "%sx%s" % [_resolution.x, _resolution.y]
		
		resolution_option_button.add_item(label)


func add_window_modes() -> void:
	for key in GUI.Window_Modes:
		var label: String = ""
		
		match GUI.Window_Modes[key]:
			0:
				label = "Windowed"
			1:
				label = "Fullscreen"
			2:
				label = "Exclusive Fullscreen"
		
		windows_option_button.add_item(label)


func add_aspect_ratios() -> void:
	for key in GUI.Aspect_Ratios:
		var label: String = ""
		
		match GUI.Aspect_Ratios[key]:
			0:  # Fit to Window
				label = "Fit to Window"
			1:  # 5:4
				label = "%s:%s" % ["5", "4"]
			2:  # 4:3
				label = "%s:%s" % ["4", "3"]
			3:  # 3:2
				label = "%s:%s" % ["3", "2"]
			4:  # 16:10
				label = "%s:%s" % ["16", "10"]
			5:  # 16:9
				label = "%s:%s" % ["16", "9"]
			6:  # 21:9
				label = "%s:%s" % ["21", "9"]
		
		aspect_ratio_button.add_item(label)


func disable_resolutions() -> void:
	resolution_option_button.disabled = true


func enable_resolutions() -> void:
	resolution_option_button.disabled = false


func _on_apply_pressed() -> void:
	
	print("Apply settings")
	print("Resolution %s" % resolution)
	
	GUI.current_resolution = resolution
	GUI.current_window_mode = window_mode
	GUI.current_gui_aspect_ratio = gui_aspect_ratio
	
	UserConfig.set_video_pref(resolution, window_mode, gui_aspect_ratio)
	UserConfig.apply_user_pref_section(UserConfig.VIDEO_SECTION)


func _on_reset_pressed() -> void:
	resolution = GUI.DEFAULT_RESOLUTION
	window_mode = GUI.DEFAULT_WINDOW_MODE
	gui_aspect_ratio = GUI.DEFAULT_GUI_ASPECT_RATIO
	
	GUI.set_resolution(resolution)
	resolution_option_button.select(resolution)
	GUI.set_window_mode(window_mode)
	windows_option_button.select(window_mode)
	
	var _gui_aspect_ratio = GUI.get_aspect_ratio(gui_aspect_ratio)
	aspect_ratio_changed.emit(_gui_aspect_ratio)
	aspect_ratio_button.select(gui_aspect_ratio)
	GUI.reset()
