class_name ChartEditor
extends BaseUIScreen

const FILE_EXTENSION: String = ".dat"

@export_dir var save_directory: String
@export_file_path var main_menu_path: String

@export_category("Dependencies")
@export_group("Nodes")
@export var file_menu_bar: FileMenuBar
@export var controls_ui: ControlsUI
@export var audio_spectrum_analyzer: AudioSpectrumAnalyzer
@export var scroll_container: ScrollContainer
@export var cursor: Cursor
@export var loading_screen: ColorRect
@export var note_grid: NoteGrid
#@export var conductor: ChartConductor
@export var shinobu_conductor: ShinobuConductor
@export var audio_file_dialog: FileDialog
@export var beat_map_file_dialog: FileDialog
@export var load_map_file_dialog: FileDialog
@export var export_file_dialog: FileDialog
@export var accept_dialog: AcceptDialog
@export_group("")
@export_group("Prefab")
@export var saved_label_prefab: PackedScene


var current_file_path: String = ""
var current_audio_file_path: String = ""
var default_save_file_name: String = "save_chart"
var file_name: String = "":
	set(value):
		file_name = value
		controls_ui.set_file_name(file_name)

var audio_name: String = "":
	set(value):
		audio_name = value
		controls_ui.set_audio_name(audio_name)

var default_info_name: String = "Info"

#var import_audio_file_dialog: FileAccessWeb = FileAccessWeb.new()


func _ready() -> void:
	#import_audio_file_dialog.loaded.connect(_on_import_audio_file_loaded)
	#import_audio_file_dialog.error.connect(_file_error)
	title = "Editor"
	state = MainUIScreen.UI_Screens.CHART_EDITOR
	
	file_menu_bar.import_audio_file_pressed.connect(_on_import_audio_file_pressed)
	file_menu_bar.load_pressed.connect(_on_load_pressed)
	file_menu_bar.save_pressed.connect(_on_save_pressed)
	file_menu_bar.save_as_pressed.connect(_on_save_as_pressed)
	file_menu_bar.quit_pressed.connect(_on_quit_pressed)
	file_menu_bar.export_pressed.connect(_on_export_pressed)
	
	var resource_path: String = ""
	
	if shinobu_conductor.sound_file != null:
		resource_path = shinobu_conductor.sound_file
	
	audio_name = Utils.get_file_name(resource_path, "")


func _on_save_pressed() -> void:
	print(current_file_path)
	
	if current_file_path == "":
		_on_save_as_pressed()
	else:
		# Create save file
		var save_file: FileAccess = FileAccess.open(current_file_path, FileAccess.WRITE)
		
		if FileAccess.get_open_error() == OK:
			print("Save file created at %s" % [current_file_path])
		
		file_name = Utils.get_file_name(current_file_path, ".dat")
		save(save_file)


func _on_save_as_pressed() -> void:
	beat_map_file_dialog.current_dir = save_directory
	beat_map_file_dialog.show()


func _on_load_pressed() -> void:
	load_map_file_dialog.current_dir = save_directory
	load_map_file_dialog.show()


func _on_quit_pressed() -> void:
	CHANGING_SCENE.emit(Vector2.ZERO, "", MainUIScreen.UI_Screens.MAIN_MENU)


func _on_import_audio_file_pressed() -> void:
	print("Open file system")
	#import_audio_file_dialog.open(".wav, .ogg")
	
	audio_file_dialog.show()


func _on_audio_file_dialog_file_selected(path: String) -> void:
	var _audio_stream: AudioStream = Utils.create_audio_stream(path)
	
	current_audio_file_path = path
	audio_name = Utils.get_file_name(path, "")
	shinobu_conductor.load_stream(path)


func _on_beat_map_file_dialog_file_selected(path: String) -> void:
	# Create save file
	var save_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	
	if FileAccess.get_open_error() == OK:
		print("Save file created at %s" % [path])
	
	current_file_path = path
	file_name = Utils.get_file_name(path, ".dat")
	save(save_file)


func _on_load_beat_map_file_dialog_file_selected(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	#var info_file_path: String = path.get_base_dir() + "/" + "info.dat"
	#
	#print(info_file_path)
	#
	#var info_file: FileAccess = FileAccess.open(info_file_path, FileAccess.READ)
	
	#print("Path %s" % path)
	
	if FileAccess.get_open_error() != OK:
		print("Could not file %s" % FileAccess.get_open_error())
		return
	
	current_file_path = path
	file_name = Utils.get_file_name(path, ".dat")
	
	loading_file(file)


func _on_export_file_dialog_file_selected(path: String) -> void:
	var base_path: String = path.get_base_dir()
	
	#var info_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	#
	#if FileAccess.get_open_error() == OK:
		#print("Save file created at %s" % [path])
	#else:
		#print(FileAccess.get_open_error())
	
	export(path, base_path)


func _on_accept_dialog_confirmed() -> void:
	audio_file_dialog.show()


func _on_import_audio_file_loaded(imported_file_name: String, file_type: String, base64_data: String) -> void:
	#var audio_stream: AudioStream = Utils.create_audio_stream(path)
	
	print("Loaded")
	print("Imported file name %s" % imported_file_name)
	print("File Type %s" % file_type)
	
	match file_type:
		"application/wav":
			var buffer = Marshalls.base64_to_raw(base64_data)
			var audio_stream: AudioStreamWAV = AudioStreamWAV.new()
			audio_stream.format = AudioStreamWAV.FORMAT_16_BITS
			audio_stream.mix_rate = 44100
			audio_stream.stereo = true
			audio_stream.data = buffer
			
			#conductor.load_stream(audio_stream)
		"application/ogg":
			var buffer = Marshalls.base64_to_raw(base64_data)
			var _audio_stream: AudioStreamOggVorbis = AudioStreamOggVorbis.load_from_buffer(buffer)
			
			#conductor.load_stream(audio_stream)
	
	
	current_audio_file_path = imported_file_name
	audio_name = Utils.get_file_name(imported_file_name, "")
	
	#controls_ui.enable_save_buttons()
	#conductor.load_stream(audio_stream)


func _on_export_pressed() -> void:
	export_file_dialog.current_file = "info"
	export_file_dialog.show()


func _file_error() -> void:
	push_error("Error!")


func export(info_file: String, path: String) -> void:
	print("EXPORT INFO DATA")
	
	pause()
	
	var controls_info: Dictionary = controls_ui.export()
	print(controls_info)
	var file_reader: FileReader = FileReader.new()
	file_reader.info_create(info_file, controls_info)
	
	print("EXPORT BEATMAP")
	
	print(path)
	
	var beatmap_file_name: String = controls_info[CustomMusicManager.Library_Keys.DIFFICULTY]
	
	print(beatmap_file_name)
	
	var result: Array = note_grid.get_all_notes()
	
	
	#var file: FileAccess = FileAccess.open(path + "/" + beatmap_file_name + ".txt", FileAccess.WRITE)
	
	var exported_bpm: float = audio_spectrum_analyzer.bpm
	var exported_offset: float = audio_spectrum_analyzer.song_offset
	
	var events: Dictionary = {
	}
	
	file_reader.beatmap_create(path + "/" + beatmap_file_name + ".dat", result, events, exported_offset, exported_bpm)
	#file.store_float(exported_bpm)
	#file.store_float(exported_offset)
	#
	#for note: ChartNote in result:
		#var format: String = "%s:%s%s%s%s\n" % [note.beat, note.type, note.lane, note.direction, note.direction_2]
		#print(format)
		#
		#file.store_string(format)
	
	unpause()


func save(save_file: FileAccess) -> void:
	print("BEGIN SAVING DATA")
	
	pause()
	
	print("SAVE INFO DATA")
	var song_properties: Dictionary = controls_ui.export()
	
	var song_name: String = song_properties[CustomMusicManager.Library_Keys.SONG_NAME]
	var artist: String = song_properties[CustomMusicManager.Library_Keys.ARTIST]
	var credit: String = song_properties[CustomMusicManager.Library_Keys.CREDIT]
	var cover_path: String = song_properties[CustomMusicManager.Library_Keys.COVER_PATH]
	var difficulty: String = song_properties[CustomMusicManager.Library_Keys.DIFFICULTY]
	var song_start_preview: float = song_properties[CustomMusicManager.Library_Keys.SONG_PREVIEW_START]
	var song_end_preview: float = song_properties[CustomMusicManager.Library_Keys.SONG_PREVIEW_END]
	
	save_file.store_pascal_string(song_name)
	save_file.store_pascal_string(artist)
	save_file.store_pascal_string(credit)
	save_file.store_pascal_string(cover_path)
	save_file.store_pascal_string(difficulty)
	save_file.store_float(song_start_preview)
	save_file.store_float(song_end_preview)
	
	var _audio_path: String = ""
	
	print("Current audio file path %s" % current_audio_file_path)
	if current_audio_file_path.is_empty():
		_audio_path = shinobu_conductor.sound_file
	else:
		_audio_path = current_audio_file_path
	
	print("Saved audio path %s" % _audio_path)
	
	# First save the song settings
	var _bpm: float = audio_spectrum_analyzer.bpm
	var _beat_duration: GlobalSettings.Duration = audio_spectrum_analyzer.beat_duration
	var _offset: float = audio_spectrum_analyzer.song_offset
	
	save_file.store_pascal_string(_audio_path)
	save_file.store_float(_bpm)
	save_file.store_8(_beat_duration)
	save_file.store_float(_offset)
	
	# Get all notes that needs to be saved
	var _notes: Dictionary = note_grid._cells
	
	if _notes.is_empty():
		print("No notes to save continue.")
	else:
		for key: Vector2 in _notes:
			#print(key)
			
			var _cell: Vector2 = key
			var _note: ChartNote = _notes[key][NoteGrid.Keys.NOTE]
			
			var _note_beat: float = _note.beat
			var _note_type: ChartNote.Note_Type = _note.type
			var _note_lane: int = _note.lane
			var _direction: int = _note.direction
			var _direction_2: int = _note.direction_2
			
			var _note_time: float = _note._time
			var _note_ticks: float = _note._ticks
			
			var _position: Vector2 = _note.position
			
			save_file.store_float(_cell.x)
			save_file.store_float(_cell.y)
			#save_file.store_float(_note_beat)
			save_file.store_float(_note_ticks)
			save_file.store_8(_note_type)
			#save_file.store_8(_note_lane)
			save_file.store_8(_direction)
			save_file.store_8(_direction_2)
			
			save_file.store_var(_position)
		save_file.close()
	
	unpause()
	
	var saved_label: SavedLabel = saved_label_prefab.instantiate()
	add_child(saved_label)
	
	await saved_label.finished
	
	print("FINISHED SAVING")


func loading_file(load_file: FileAccess) -> void:
	print("LOADING FILE")
	print("Load file %s" % [current_file_path])
	
	pause()
	
	scroll_container.scroll_horizontal = 0
	
	#print("Clear Grid")
	note_grid.clear_grid()
	
	#await get_tree().create_timer(1.0).timeout

	var song_name: String = load_file.get_pascal_string()
	var artist: String = load_file.get_pascal_string()
	var credit: String = load_file.get_pascal_string()
	var cover_path: String = load_file.get_pascal_string()
	var difficulty: String = load_file.get_pascal_string()
	var song_start_preview: float = load_file.get_float()
	var song_end_preview: float = load_file.get_float()
	
	var dictionary: Dictionary = {
		CustomMusicManager.Library_Keys.SONG_NAME: song_name,
		CustomMusicManager.Library_Keys.ARTIST: artist,
		CustomMusicManager.Library_Keys.CREDIT: credit,
		CustomMusicManager.Library_Keys.COVER_PATH: cover_path,
		CustomMusicManager.Library_Keys.DIFFICULTY: difficulty,
		CustomMusicManager.Library_Keys.SONG_PREVIEW_START: song_start_preview,
		CustomMusicManager.Library_Keys.SONG_PREVIEW_END: song_end_preview,
	}
	
	controls_ui.set_song_properties(dictionary)

	var _audio_path: String = load_file.get_pascal_string()
	
	if not _audio_path.is_empty():
		current_audio_file_path = _audio_path
	
	print("Audio Path %s" % _audio_path)
	
	var _bpm: float = load_file.get_float()
	var _beat_duration: GlobalSettings.Duration = load_file.get_8() as GlobalSettings.Duration
	var _song_offset: float = load_file.get_float()
	
	var audio_stream: AudioStream = Utils.create_audio_stream(current_audio_file_path)
	if audio_stream != null:
		shinobu_conductor.load_stream(current_audio_file_path)
		audio_name = Utils.get_file_name(current_audio_file_path, "")
		
		GlobalSettings.bpm = _bpm
		GlobalSettings.beat_duration = _beat_duration
		GlobalSettings.song_offset = _song_offset
		
		print("BPM %s Beat Duration %s Song Offset %s" % [_bpm, _beat_duration, _song_offset])
		
		var _notes: Dictionary = {}
		
		print("Read notes")
		while load_file.get_position() < load_file.get_length():
			# Read data
			# Key
			var _cell_x: float = load_file.get_float()
			var _cell_y: float = load_file.get_float()
			var _cell: Vector2 = Vector2(_cell_x, _cell_y)
			
			# Public Note variables
			#var _beat: float = load_file.get_float() / 4
			var _ticks: float = load_file.get_float()
			var _note_type: ChartNote.Note_Type = load_file.get_8() as ChartNote.Note_Type
			#var _note_lane: int = load_file.get_8()
			var _direction: int = load_file.get_8()
			var _direction_2: int = load_file.get_8()
			
			var _position: Vector2 = load_file.get_var()
			
			#var _note: Note = Note.new(_beat, _note_type, _note_lane, _direction, _direction_2)
			_notes[_cell] = [_note_type, _direction, _direction_2, _position, _ticks]
			
			#await get_tree().process_frame
			
			#print("Cell %s Note %s" % [_cell, _note])
			#print(_notes)
		await get_tree().process_frame
		#await get_tree().create_timer(0.5).timeout
		
		#print("Load notes")
		note_grid.load_notes(_notes)
	else:
		accept_dialog.show()
		print("No audio stream re-import audio file.")
	
	load_file.close()
	
	unpause()
	print("FINISHED LOADING")


func pause() -> void:
	loading_screen.show()
	ChartEditorInputManager.is_paused = true
	cursor.pause()


func unpause() -> void:
	ChartEditorInputManager.is_paused = false
	cursor.unpause()
	loading_screen.hide()


func change_scene() -> void:
	Loader.load_scene(self, main_menu_path, get_parent())
	GlobalBackground.appear_shader()
