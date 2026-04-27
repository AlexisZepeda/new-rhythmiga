class_name CustomMusicManager

const WAV_EXTENSION: String = "wav"
const OGG_EXTENSION: String = "ogg"

enum Library_Keys {
	SONG_PATH,
	SONG_NAME,
	ARTIST,
	COVER_PATH,
	EASY_CHART_PATH,
	MEDIUM_CHART_PATH,
	HARD_CHART_PATH,
	CREDIT,
	DIFFICULTY,
	SONG_PREVIEW_START,
	SONG_PREVIEW_END,
}

static var music_folder: String = "user://CustomMusic/"

static var library: Dictionary = {}

static var current_id: String = ""
static var current_difficulty: Enums.Difficulty = Enums.Difficulty.EASY


static func _create_directory(path: String) -> void:
		var dir: Error = DirAccess.make_dir_absolute(path)
		
		if dir != OK:
			print(DirAccess.get_open_error())
		else:
			print("Created Music Folder")


static func _open_directory(path: String) -> void:
		var dir: DirAccess = DirAccess.open(path)
		var files: PackedStringArray = dir.get_directories()
		
		for file: String in files:
			if check_valid_folder(file):
				open_folder(file)


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


static func check_valid_chart_files(array: PackedStringArray) -> PackedStringArray:
	var result: PackedStringArray = []
	
	for file: String in array:
		if file.begins_with("EASY"):
			result.append(file)
		elif file.begins_with("MEDIUM"):
			result.append(file)
		elif file.begins_with("HARD"):
			result.append(file)
	
	return result


static func check_valid_info_dat(array: PackedStringArray) -> String:
	for file: String in array:
		if file == "info.dat":
			return file
	
	return ""


## Returns [member Library_Keys.ARTIST if [param key] is in [member library].
static func get_artist_name(key: String) -> String:
	if library.has(key):
		return library[key][Library_Keys.ARTIST]
	else:
		return ""


static func get_library_size() -> int:
	if library.is_empty():
		return 0
	else:
		return library.size()


static func get_song_key(index: int) -> String:
	if library.is_empty():
		return ""
	
	var count: int = 0
	
	for key: String in library:
		if count == index:
			return key
		
		count += 1
	
	return ""


## Returns [member Library_Keys.SONG_NAME] if [param key] is in [member library].
static func get_song_name(key: String) -> String:
	if library.has(key):
		return library[key][Library_Keys.SONG_NAME]
	else:
		return ""


## Returns [member Library_Keys.SONG_PATH] if [param key] is in [member library].
static func get_song_path_on_key(key: String) -> String:
	if library.has(key):
		return library[key][Library_Keys.SONG_PATH]
	else:
		return ""


static func get_song_path(id: String) -> String:
	for key: String in library:
		if library[key][Library_Keys.SONG_NAME] == id:
			return library[key][Library_Keys.SONG_PATH]
	
	return ""


## Returns [AudioStream] using [member Library_Keys.SONG_NAME].
static func load_audio(song_name: String) -> AudioStream:
	var file = get_song_path(song_name)
	
	var stream: AudioStream
	
	match file.get_extension():
		CustomMusicManager.WAV_EXTENSION:
			stream = AudioStreamWAV.load_from_file(file)
		CustomMusicManager.OGG_EXTENSION:
			stream = AudioStreamOggVorbis.load_from_file(file)
	
	return stream

## Returns [AudioStream] using [member Library_Keys.SONG_PATH].
static func load_audio_on_path(song_path: String) -> AudioStream:
	var stream: AudioStream
	
	match song_path.get_extension():
		CustomMusicManager.WAV_EXTENSION:
			stream = AudioStreamWAV.load_from_file(song_path)
		CustomMusicManager.OGG_EXTENSION:
			stream = AudioStreamOggVorbis.load_from_file(song_path)
	
	return stream


static func load_artist_name() -> String:
	if current_id.is_empty():
		return ""
	
	return library[current_id][Library_Keys.ARTIST]


static func load_beat_map(id: String, difficulty: Enums.Difficulty) -> String:
	var result: String = ""
	
	match difficulty:
		Enums.Difficulty.EASY:
			result = library[id][Library_Keys.EASY_CHART_PATH]
		Enums.Difficulty.MEDIUM:
			result = library[id][Library_Keys.MEDIUM_CHART_PATH]
		Enums.Difficulty.HARD:
			result = library[id][Library_Keys.HARD_CHART_PATH]
	
	if not result.is_empty():
		current_id = id
		current_difficulty = difficulty
	
	return result


static func load_cover_art() -> String:
	if current_id.is_empty():
		return ""
	
	return library[current_id][Library_Keys.COVER_PATH]


static func load_custom_music_directory() -> void:
	if DirAccess.dir_exists_absolute(music_folder):
		_open_directory(music_folder)
	else:
		_create_directory(music_folder)


static func load_song_name() -> String:
	if current_id.is_empty():
		return ""
	
	return library[current_id][Library_Keys.SONG_NAME]


static func load_song_path(id: String) -> String:
	if id.is_empty():
		return ""
	
	return library[id][Library_Keys.SONG_PATH]


static func open_folder(folder_name: String) -> void:
	var path: String = music_folder + folder_name
	var folder: DirAccess = DirAccess.open(path)
	
	var files: PackedStringArray = folder.get_files()
	var valid_files: PackedStringArray = check_valid_music_files(files)
	var info_dat: String = check_valid_info_dat(files)
	var beatmaps: PackedStringArray = check_valid_chart_files(files)
	
	if not library.has(folder_name):
		library[folder_name] = {
			Library_Keys.SONG_PATH: "",
			Library_Keys.SONG_NAME: "",
			Library_Keys.ARTIST: "",
			Library_Keys.COVER_PATH: "",
			Library_Keys.EASY_CHART_PATH: "",
			Library_Keys.MEDIUM_CHART_PATH: "",
			Library_Keys.HARD_CHART_PATH: "",
		}
	
	## Only one audio file in folder may be used.
	if not valid_files.is_empty():
		var music_file_path: String = "%s/%s" % [path, valid_files.get(0)]
		
		if library[folder_name][Library_Keys.SONG_PATH] != music_file_path:
			library[folder_name][Library_Keys.SONG_PATH] = music_file_path
		#else:
			#print("")
	else:
		print("Folder contains no music")
	
	## Get info.dat
	if info_dat != "":
		var file: FileAccess = FileAccess.open(path + "/" + info_dat, FileAccess.READ)
		
		if FileAccess.get_open_error() != OK:
			print(FileAccess.get_open_error())
			return
		#else:
			#print("Opened %s" % [info_dat])
		
		var dictionary: Dictionary = file.get_var()
		
		library[folder_name][Library_Keys.SONG_NAME] = dictionary[Library_Keys.SONG_NAME]
		library[folder_name][Library_Keys.ARTIST] = dictionary[Library_Keys.ARTIST]
		library[folder_name][Library_Keys.COVER_PATH] = dictionary[Library_Keys.COVER_PATH]
		
	
	## Get beatmap paths
	if not beatmaps.is_empty():
		for file: String in beatmaps:
			if file.begins_with("EASY"):
				var beatmap_file_path: String = "%s/%s" % [path, file]
				library[folder_name][Library_Keys.EASY_CHART_PATH] = beatmap_file_path
			elif file.begins_with("MEDIUM"):
				var beatmap_file_path: String = "%s/%s" % [path, file]
				library[folder_name][Library_Keys.MEDIUM_CHART_PATH] = beatmap_file_path
			elif file.begins_with("HARD"):
				var beatmap_file_path: String = "%s/%s" % [path, file]
				library[folder_name][Library_Keys.HARD_CHART_PATH] = beatmap_file_path
