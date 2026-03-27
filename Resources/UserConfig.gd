class_name UserConfig
extends Resource

@export_file_path("*.cfg") var path: String = "res://Saves"

const DEFAULT_FILE_NAME: String = "userconfig.cfg"

const VIDEO_SECTION = "Video"
const AUDIO_SECTION = "Audio"

static var config_file: ConfigFile = ConfigFile.new()

# UserConfig Settings
static var is_audio_pref_applied: bool = false
static var is_video_pref_applied: bool = false

# Video User Settings
static var resolution: GUI.Base_Resolutions = GUI.Base_Resolutions.WXGA_1280x720
static var gui_aspect_ratio: GUI.Aspect_Ratios = GUI.Aspect_Ratios.Fit_To_Window
static var window_mode: GUI.Window_Modes = GUI.Window_Modes.WINDOWED

# Audio User Settings
static var master_audio_level: float = 1.0
static var music_audio_level = 1.0
static var sfx_audio_level = 1.0


func load_config() -> void:
	var file: String = "%s/%s" % [path, DEFAULT_FILE_NAME]
	
	print("LOADING FROM PATH %s" % file)
	
	var err: Error = config_file.load(file)
	
	if err != OK:
		return
	
	for section in config_file.get_sections():
		match section:
			VIDEO_SECTION:
				resolution = config_file.get_value(section, "resolution", GUI.Base_Resolutions.WXGA_1280x720)
				gui_aspect_ratio = config_file.get_value(section, "gui_aspect_ratio", GUI.Aspect_Ratios.Fit_To_Window)
				window_mode = config_file.get_value(section, "window_mode", GUI.Window_Modes.WINDOWED)
			AUDIO_SECTION:
				master_audio_level = config_file.get_value(section, "master_volume", master_audio_level)
				music_audio_level = config_file.get_value(section, "music_volume", music_audio_level)
				sfx_audio_level = config_file.get_value(section, "sfx_volume", sfx_audio_level)
	
	#print_user_pref()
	set_user_preferences()


func save_config() -> void:
	var file: String = "%s/%s" % [path, DEFAULT_FILE_NAME]
	
	print("SAVING TO PATH %s" % file)
	
	#config_file.set_value(VIDEO_SECTION, "resolution", GUI.current_resolution)
	#config_file.set_value(VIDEO_SECTION, "gui_aspect_ratio", GUI.current_gui_aspect_ratio)
	#config_file.set_value(VIDEO_SECTION, "window_mode", GUI.current_window_mode)
	
	#config_file.set_value(AUDIO_SECTION, "master_volume", master_audio_level)
	#config_file.set_value(AUDIO_SECTION, "music_volume", music_audio_level)
	#config_file.set_value(AUDIO_SECTION, "sfx_volume", sfx_audio_level)
	if config_file.save(file) == OK:
		print("Saved config file")
		is_audio_pref_applied = false
		is_video_pref_applied = false


static func apply_user_pref_section(section: String) -> void:
	match section:
		VIDEO_SECTION:
			config_file.set_value(VIDEO_SECTION, "resolution", GUI.current_resolution)
			config_file.set_value(VIDEO_SECTION, "gui_aspect_ratio", GUI.current_gui_aspect_ratio)
			config_file.set_value(VIDEO_SECTION, "window_mode", GUI.current_window_mode)
			
			is_audio_pref_applied = true
		AUDIO_SECTION:
			config_file.set_value(AUDIO_SECTION, "master_volume", master_audio_level)
			config_file.set_value(AUDIO_SECTION, "music_volume", music_audio_level)
			config_file.set_value(AUDIO_SECTION, "sfx_volume", sfx_audio_level)
			
			is_video_pref_applied = true


func set_user_preferences() -> void:
	GUI.current_resolution = resolution
	GUI.current_gui_aspect_ratio = gui_aspect_ratio
	GUI.current_window_mode = window_mode
	
	GUI.set_resolution()
	GUI.set_window_mode()
	
	var _bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(_bus, linear_to_db(master_audio_level))
	_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(_bus, linear_to_db(music_audio_level))
	_bus = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(_bus, linear_to_db(sfx_audio_level))


static func set_audio_pref(master: float, music: float, sfx: float) -> void:
	master_audio_level = master
	music_audio_level = music
	sfx_audio_level = sfx


static func set_video_pref(res: GUI.Base_Resolutions, window: GUI.Window_Modes, aspect_ratio: GUI.Aspect_Ratios) -> void:
	resolution = res
	window_mode = window
	gui_aspect_ratio = aspect_ratio
	
	print("SETTING VIDEO PREFERENCES")
	print_user_pref()


static func print_user_pref() -> void:
	print("Resolution %s" % GUI.RESOLUTIONS.keys()[resolution])
	print("Window Mode %s" % GUI.WINDOW_MODES.keys()[window_mode])
	print("GUI Aspect %s" % GUI.ASPECT_RATIOS.keys()[gui_aspect_ratio])
