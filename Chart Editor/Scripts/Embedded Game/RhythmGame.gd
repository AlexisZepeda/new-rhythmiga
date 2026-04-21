class_name RhythmGame
extends Node2D

signal game_finished

#@export_category("Chart")
#@export var chart: ChartData.Chart = ChartData.Chart.SYNC_TEST
@export_file var data: String 

@export_category("Node Dependencies")
@export_group("Note Managers")
@export var note_manager: NoteManager
@export var note_manager_2: NoteManager
@export var note_manager_3: NoteManager
@export var note_manager_4: NoteManager
@export_group("")

@export_group("Judgement Sprites")
@export var lane_1: Sprite2D
@export var lane_2: Sprite2D
@export var lane_3: Sprite2D
@export var lane_4: Sprite2D
@export_group("")
@export var current_notes: CurrentNotes
@export var play_stats: CurrentGameStats

@export var game_manager: GameManager

#@export var conductor: ChartConductor
@export var shinobu_conductor: ShinobuConductor

@export var game_ui: Control
@export var debug_ui: Control

enum Game_Version {
	CHART_EDITOR,
	MAIN_GAME,
}

const QUEUE_SIZE: int = 4
#const BAR_LINE_SCENE = preload("res://Scenes/UI/Utility/Beat_Line.tscn")

var _window_height: float = 0.0

var queue: PriorityQueue = PriorityQueue.new(QUEUE_SIZE)
var bpm: float = 0.0
var song_offset_sec: float = 0.0
var judgement_line: float = 0.0

var state: Game_Version = Game_Version.MAIN_GAME

var notes: Array = []

func _ready() -> void:
	play_stats.reset()


func _process(_delta: float) -> void:
	var note_delta_1: float = note_manager.get_note_delta_of_first_note()
	var note_delta_2: float = note_manager_2.get_note_delta_of_first_note()
	var note_delta_3: float = note_manager_3.get_note_delta_of_first_note()
	var note_delta_4: float = note_manager_4.get_note_delta_of_first_note()
	
	debug_ui.set_note_delta_labels(note_delta_1, note_delta_2, note_delta_3, note_delta_4)
	
	game_manager.lane_queue = queue


func _init_game_window() -> void:
	_window_height = (get_viewport().size_2d_override.y - 100) / 5.0
	judgement_line = get_viewport().size_2d_override.x * 0.8
	EmbeddedGlobalSettings.judgement_line = judgement_line
	
	lane_1.position = Vector2(judgement_line, _window_height)
	lane_2.position = Vector2(judgement_line, _window_height * 2)
	lane_3.position = Vector2(judgement_line, _window_height * 3)
	lane_4.position = Vector2(judgement_line, _window_height * 4)


func _init_game_ui_signals() -> void:
	game_ui.init_game_signals(note_manager)
	game_ui.init_game_signals(note_manager_2)
	game_ui.init_game_signals(note_manager_3)
	game_ui.init_game_signals(note_manager_4)


func _init_game_ui() -> void:
	game_ui.set_song_panel()


func _init_text_notes(_notes: Array) -> void:
	#note_manager.set_note_beats(notes)
	#note_manager.create_notes(50.0)
	
	note_manager.create_notes(_window_height) #50
	note_manager_2.create_notes(_window_height * 2) #100
	note_manager_3.create_notes(_window_height * 3) #150
	note_manager_4.create_notes(_window_height * 4) #200
	
	init_game()


func _parse_data_text(file: String) -> Array:
	var beats: Array = []
	var _beat_dictionary: Dictionary = {}
	var regex: RegEx = RegEx.new()
	regex.compile("^[^:]+")
	
	#print(file)
	
	if FileAccess.file_exists(file):
		var text_file: FileAccess = FileAccess.open(file, FileAccess.READ)
		#var content = text_file.get_as_text()
		
		bpm = text_file.get_float()
		song_offset_sec = text_file.get_float()
		
		shinobu_conductor.BPM = bpm
		shinobu_conductor.first_beat_offset_ms = int(song_offset_sec * 1000)
		
		print("song offset sec %s" % song_offset_sec)
		
		while not text_file.eof_reached():
			var line = text_file.get_line()
			var result: RegExMatch = regex.search(line)
			
			if result:
				beats.append(float(result.get_string()))
				#print(result.get_string())
				var beat: float = float(result.get_string())
				var tick: float = float(((beat / GlobalSettings.Duration.SIXTEENTH)) * GlobalSettings.PPQ)
				
				#print("Normal beat %s" % beat)
				#print("Beat %s" % ((beat) / GlobalSettings.Duration.SIXTEENTH))
				#print("Tick %s" % tick)
				
				var separator: int = line.find(":")
				
				var content: String = line.substr(separator + 1)
				
				var note_type: int = int(content[0])
				var note_lane: int = int(content[1])
				var direction: int = int(content[2])
				var direction_2: int = int(content[3])
				
				_beat_dictionary[beat] = [note_type, note_lane, direction, direction_2]
				
				match note_lane:
					0:
						note_manager.set_notes(beat, note_type, direction, direction_2, tick)
					1:
						note_manager_2.set_notes(beat, note_type, direction, direction_2, tick)
					2:
						note_manager_3.set_notes(beat, note_type, direction, direction_2, tick)
					3:
						note_manager_4.set_notes(beat, note_type, direction, direction_2, tick)
				
				#print("Type %s Lane %s Direction %s" % [note_type, note_lane, direction])
		#print(content)
	else:
		printerr("File not found.")
	
	return beats


func _reinit_queue() -> void:
	#print("	Reint queue")
	queue = null
	queue = PriorityQueue.new(QUEUE_SIZE)
	
	var note_delta_1: float = note_manager.get_note_delta_of_first_note()
	var note_delta_2: float = note_manager_2.get_note_delta_of_first_note()
	var note_delta_3: float = note_manager_3.get_note_delta_of_first_note()
	var note_delta_4: float = note_manager_4.get_note_delta_of_first_note()
	
	queue.push(note_manager, note_delta_1)
	queue.push(note_manager_2, note_delta_2)
	queue.push(note_manager_3, note_delta_3)
	queue.push(note_manager_4, note_delta_4)
	
	debug_ui.print_queue(queue)


func _on_notes_array_change() -> void:
	_reinit_queue()


func _on_notes_2_array_change() -> void:
	_reinit_queue()


func _on_notes_3_array_change() -> void:
	_reinit_queue()


func _on_notes_4_array_change() -> void:
	_reinit_queue()


func _on_conductor_finished() -> void:
	await game_ui.finish_animation()
	
	game_finished.emit()


func _on_current_notes_changed() -> void:
	note_manager.flush_notes()
	note_manager_2.flush_notes()
	note_manager_3.flush_notes()
	note_manager_4.flush_notes()
	
	# Refresh Note Managers
	for beat in current_notes.current_notes:
		for note: ChartNote in current_notes.current_notes[beat]:
			var note_type: int = int(note.type)
			var note_lane: int = int(note.lane)
			var direction: int = int(note.direction)
			var direction_2: int = int(note.direction_2)
			var tick: float = note._ticks
			
			match note_lane:
				0:
					note_manager.set_notes(beat, note_type, direction, direction_2, tick)
				1:
					note_manager_2.set_notes(beat, note_type, direction, direction_2, tick)
				2:
					note_manager_3.set_notes(beat, note_type, direction, direction_2, tick)
				3:
					note_manager_4.set_notes(beat, note_type, direction, direction_2, tick)
	
	_init_text_notes([])


func init_beatmap(file: String) -> void:
	#print(file)
	
	notes = _parse_data_text(file)
	play_stats.total_notes = notes.size()
	_init_text_notes(notes)
	
	#print("BPM %s" % bpm)
	#print("First beat offset %s" % int(song_offset_sec * 1000))
	
	await game_ui.start_animation()
	
	shinobu_conductor.play(0)


func init_game() -> void:
	queue.push(note_manager, note_manager.get_note_delta_of_first_note())
	queue.push(note_manager_2, note_manager_2.get_note_delta_of_first_note())
	queue.push(note_manager_3, note_manager_3.get_note_delta_of_first_note())
	queue.push(note_manager_4, note_manager_4.get_note_delta_of_first_note())
	
	debug_ui.print_queue(queue)


func init_rhythm_game(game_state: Game_Version) -> void:
	state = game_state
	play_stats.reset()
	
	match state:
		Game_Version.CHART_EDITOR:
			_init_game_window()
			_init_game_ui_signals()
			
			current_notes.changed.connect(_on_current_notes_changed)
		Game_Version.MAIN_GAME:
			_init_game_window()
			_init_game_ui_signals()
			_init_game_ui()
	
	shinobu_conductor.finished.connect(_on_conductor_finished)


func reset() -> void:
	_on_current_notes_changed()
	play_stats.reset()
