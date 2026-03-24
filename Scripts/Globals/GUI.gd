extends Node

enum Base_Resolutions {
	FOURK_UHD_1_3840X2160,
	WQHD_2560x1440,
	FHD_1920x1080,
	WXGA_HD_1366x768,
	WXGA_1280x720,
	WSXGA_1440x900,
	HDPLUS_1600x900,
	WSVGA_1024x600,
	SVGA_800x600,
}

enum Aspect_Ratios {
	Fit_To_Window,
	Early_Television,
	Fullscreen,
	Film_35mm,
	Computer_Display,
	HDTV,
	Ultrawide,
}

enum Window_Modes {
	WINDOWED,
	FULLSCREEN,
	EXCLUSIVE_FULLSCREEN,
}

const RESOLUTIONS: Dictionary[Base_Resolutions, Vector2i] = {
	Base_Resolutions.FOURK_UHD_1_3840X2160: Vector2i(3840,2160),
	Base_Resolutions.WQHD_2560x1440: Vector2i(2560,1440),
	Base_Resolutions.FHD_1920x1080: Vector2i(1920,1080),
	Base_Resolutions.WXGA_HD_1366x768: Vector2i(1366,768),
	Base_Resolutions.WXGA_1280x720: Vector2i(1280,720),
	Base_Resolutions.WSXGA_1440x900: Vector2i(1440,900),
	Base_Resolutions.HDPLUS_1600x900: Vector2i(1600,900),
	Base_Resolutions.WSVGA_1024x600: Vector2i(1024,600),
	Base_Resolutions.SVGA_800x600: Vector2i(800,600)
}

const WINDOW_MODES: Dictionary[Window_Modes, DisplayServer.WindowMode] = {
	Window_Modes.WINDOWED: DisplayServer.WindowMode.WINDOW_MODE_WINDOWED,
	Window_Modes.FULLSCREEN: DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN,
	Window_Modes.EXCLUSIVE_FULLSCREEN: DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
}

const ASPECT_RATIOS: Dictionary[Aspect_Ratios, float] = {
	Aspect_Ratios.Fit_To_Window: -1.0,
	Aspect_Ratios.Early_Television: 5.0 / 4.0,
	Aspect_Ratios.Fullscreen: 4.0 / 3.0,
	Aspect_Ratios.Film_35mm: 3.0 / 2.0,
	Aspect_Ratios.Computer_Display: 16.0 / 10.0,
	Aspect_Ratios.HDTV: 16.0 / 9.0,
	Aspect_Ratios.Ultrawide: 21.0 / 9.0,
}

const DEFAULT_RESOLUTION: Base_Resolutions = Base_Resolutions.WXGA_1280x720
const DEFAULT_WINDOW_MODE: Window_Modes = Window_Modes.WINDOWED
const DEFAULT_GUI_ASPECT_RATIO: Aspect_Ratios = Aspect_Ratios.Fit_To_Window


var current_resolution: Base_Resolutions = Base_Resolutions.WXGA_1280x720:
	set(value):
		print("Global Resolution %s" % current_resolution)
var current_window_mode: Window_Modes = Window_Modes.WINDOWED:
	set(value):
		print("Global Window Mode %s" % current_window_mode)
var current_gui_aspect_ratio: Aspect_Ratios = Aspect_Ratios.Fit_To_Window



func get_resolution(resolution: Base_Resolutions) -> Vector2i:
	return RESOLUTIONS[resolution]


func set_resolution(index: Base_Resolutions=current_resolution) -> void:
	var vector_resolution = get_resolution(index)
	get_window().set_size(vector_resolution)
	center_window()


func get_aspect_ratio(aspect_ratio: Aspect_Ratios=current_gui_aspect_ratio) -> float:
	return ASPECT_RATIOS[aspect_ratio]


func reset() -> void:
	current_resolution = DEFAULT_RESOLUTION
	current_window_mode = DEFAULT_WINDOW_MODE
	current_gui_aspect_ratio = DEFAULT_GUI_ASPECT_RATIO


func set_window_mode(mode: Window_Modes=current_window_mode) -> void:
	var window_mode: DisplayServer.WindowMode = WINDOW_MODES[mode]
	DisplayServer.window_set_mode(window_mode)


func center_window() -> void:
	var screen_center: Vector2 = Vector2(DisplayServer.screen_get_position()) + (DisplayServer.screen_get_size() / 2.0)
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(screen_center - window_size / 2.0)
