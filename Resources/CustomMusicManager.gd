class_name CustomMusicManager

const WAV_EXTENSION: String = "wav"
const OGG_EXTENSION: String = "ogg"

enum Library_Keys {
	SONG_PATH,
	SONG_NAME,
	EASY_CHART_PATH,
	MEDIUM_CHART_PATH,
	HARD_CHART_PATH,
}

static var music_folder: String = "user://CustomMusic/"

static var library: Dictionary = {}


static func _create_directory(path: String) -> void:
		var dir: Error = DirAccess.make_dir_absolute(path)
		
		if dir != OK:
			print(DirAccess.get_open_error())
		else:
			print("Created Music Folder")


static func _open_directory(path: String) -> void:
		print("Open Music Folder")
		
		var dir: DirAccess = DirAccess.open(path)
		var files: PackedStringArray = dir.get_directories()
		
		for file: String in files:
			if check_valid_folder(file):
				open_folder(file)


static func load_custom_music_directory() -> void:
	if DirAccess.dir_exists_absolute(music_folder):
		_open_directory(music_folder)
	else:
		_create_directory(music_folder)


static func open_folder(folder_name: String) -> void:
	var path: String = music_folder + folder_name
	var folder: DirAccess = DirAccess.open(path)
	
	var files: PackedStringArray = folder.get_files()
	var valid_files: PackedStringArray = check_valid_music_files(files)
	
	if not library.has(folder_name):
		library[folder_name] = {
			Library_Keys.SONG_PATH: "",
			Library_Keys.SONG_NAME: "",
			Library_Keys.EASY_CHART_PATH: "",
			Library_Keys.MEDIUM_CHART_PATH: "",
			Library_Keys.HARD_CHART_PATH: "",
		}
	
	## Only one audio file in folder may be used.
	if not valid_files.is_empty():
		var music_file_path: String = "%s/%s" % [path, valid_files.get(0)]
		
		if library[folder_name][Library_Keys.SONG_PATH] != music_file_path:
			library[folder_name][Library_Keys.SONG_NAME] = (music_file_path.get_basename()).get_file()
			library[folder_name][Library_Keys.SONG_PATH] = music_file_path
		else:
			print("")
	else:
		print("Folder contains no music")
	
	print(library)


static func check_valid_folder(folder_name: String) -> bool:
	var path: String = music_folder + folder_name
	return DirAccess.dir_exists_absolute(path)


static func check_valid_music_files(array: PackedStringArray) -> PackedStringArray:
	var result: PackedStringArray = []
	
	for file: String in array:
		match file.get_extension():
			WAV_EXTENSION, OGG_EXTENSION:
				result.append(file)
	
	return result


static func check_valid_chart_files(array: PackedStringArray) -> void:
	for file: String in array:
		if file.begins_with("EASY"):
			pass
		elif file.begins_with("MEDIUM"):
			pass
		elif file.begins_with("HARD"):
			pass


static func get_song_path(id: String) -> String:
	for key: String in library:
		if library[key][Library_Keys.SONG_NAME] == id:
			return library[key][Library_Keys.SONG_PATH]
	
	return ""
