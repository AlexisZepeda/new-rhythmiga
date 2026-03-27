extends VBoxContainer

signal aspect_ratio_changed(aspect_ratio: float)

@export_category("Options")
@export var resolution_option_button: OptionButton
@export var windows_option_button: OptionButton
@export var aspect_ratio_button: OptionButton
@export_category("")

@export var apply: Button
@export var reset: Button


func _ready() -> void:
	apply.pressed.connect(_on_apply_pressed)
	reset.pressed.connect(_on_reset_pressed)
	
	add_resolutions()
	add_aspect_ratios()
	add_window_modes()
	
	resolution_option_button.select(GUI.current_resolution)
	windows_option_button.select(GUI.current_window_mode)
	aspect_ratio_button.select(GUI.current_gui_aspect_ratio)
	
	enable_or_disable_resolutions()


func _on_resolution_option_item_selected(index: int) -> void:
	GUI.set_resolution(index)


func _on_windows_option_item_selected(index: int) -> void:
	var window_mode: GUI.Window_Modes = windows_option_button.get_item_id(index) as GUI.Window_Modes
	GUI.set_window_mode(window_mode)
	
	enable_or_disable_resolutions()


func _on_gui_aspect_ratio_item_selected(index: int) -> void:
	var _gui_aspect_ratio = GUI.get_aspect_ratio(index)
	#GUI.current_gui_aspect_ratio = index as GUI.Aspect_Ratios
	GUI.set_aspect_ratio(index)
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


func enable_or_disable_resolutions() -> void:
	print("Enable/Disable resolutions")
	print(GUI.is_fullscreen())
	if GUI.is_fullscreen():
		print("Disable resolutions")
		resolution_option_button.disabled = true
	else:
		print("Enable resolutions")
		resolution_option_button.disabled = false


func _on_apply_pressed() -> void:
	
	print("Apply settings")
	print("Resolution %s" % GUI.current_resolution)
	print("Window Mode %s" % GUI.current_window_mode)
	
	UserConfig.set_video_pref(GUI.current_resolution, GUI.current_window_mode, GUI.current_gui_aspect_ratio)
	UserConfig.apply_user_pref_section(UserConfig.VIDEO_SECTION)


func _on_reset_pressed() -> void:
	GUI.reset()
	
	var resolution: GUI.Base_Resolutions = GUI.current_resolution
	var window_mode: GUI.Window_Modes = GUI.current_window_mode
	var gui_aspect_ratio: GUI.Aspect_Ratios = GUI.current_gui_aspect_ratio
	
	GUI.set_resolution(resolution)
	resolution_option_button.select(resolution)
	GUI.set_window_mode(window_mode)
	windows_option_button.select(window_mode)
	
	var _gui_aspect_ratio = GUI.get_aspect_ratio(gui_aspect_ratio)
	aspect_ratio_changed.emit(_gui_aspect_ratio)
	aspect_ratio_button.select(gui_aspect_ratio)
