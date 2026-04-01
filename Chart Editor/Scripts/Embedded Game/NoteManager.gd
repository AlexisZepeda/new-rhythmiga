class_name NoteManager
extends Node2D

signal array_change
signal previous_note_type(note_manager: NoteManager, note_type: Enums.Note_Type)
signal play_stats_updated(_play_stats: CurrentGameStats)
signal note_hit_type(hit_type: Enums.Hit_Type, position: Vector2)

@export var rhythm_game: RhythmGame
@export var sfx_player: AudioStreamPlayer
@export var time_type: Enums.TimeType = Enums.TimeType.FILTERED
#@export var chart: ChartData.Chart = ChartData.Chart.SYNC_TEST
@export var play_stats: CurrentGameStats

const NOTE_SCENE = preload("res://Chart Editor/Scenes/Embedded Game/Notes/Tap_Note.tscn")
const SLIDE_NOTE_SCENE = preload("res://Chart Editor/Scenes/Embedded Game/Notes/Slide_Note.tscn")
const DOUBLE_SLIDE_NOTE_SCENE = preload("res://Chart Editor/Scenes/Embedded Game/Notes/Double_Slide_Note.tscn")
const LONG_NOTE_SCENE = preload("res://Chart Editor/Scenes/Embedded Game/Notes/Long_Note.tscn")
const LONG_BACK_NOTE_SCENE = preload("res://Chart Editor/Scenes/Embedded Game/Notes/Long_Back_Note.tscn")
const LONG_NOTE_LINE = preload("res://Chart Editor/Scenes/Embedded Game/Notes/Long_Note_Line.tscn")
const LONG_SLIDE_NOTE_SCENE = preload("res://Chart Editor/Scenes/Embedded Game/Notes/Long_Slide.tscn")
const LONG_DOUBLE_SLIDE_NOTE_SCENE = preload("res://Chart Editor/Scenes/Embedded Game/Notes/Long_Double_Slide.tscn")
const MAX_NOTE_DELTA = -999999999

var _notes: Array[Note] = []
var _note_beats: Array = []
var _beats: Dictionary = {}

var note_final_position: Vector2 = Vector2(0, 0)
var _last_long_note: LongNote = null

var held_key: Key = KEY_NONE
	#set(value):
		#print("Changing held key %s previous key %s" % [OS.get_keycode_string(held_key), OS.get_keycode_string(previous_key)])
		#
		#if previous_key != KEY_NONE:
			#held_key = KEY_NONE
		#else:
			#held_key = value
		#previous_note_type.emit(self, front_note_type)

var previous_key: Key = KEY_NONE
	#set(value):
		#print("Changing previous key %s" % Enums.Note_Type.keys()[front_note_type])
		#match front_note_type:
			#Enums.Note_Type.TAP:
				#previous_key = KEY_NONE
			#_:
				#previous_key = value
		#previous_note_type.emit(self, front_note_type)

var front_note_type: Enums.Note_Type = Enums.Note_Type.NONE


func _ready() -> void:
	play_stats.changed.connect(func() -> void: play_stats_updated.emit(play_stats))
	note_final_position = Vector2(EmbeddedGlobalSettings.judgement_line, 0)


func _process(_delta: float) -> void:
	if _notes.is_empty():
		front_note_type = Enums.Note_Type.NONE
		return

	var curr_beat := _get_curr_beat()
	
	for i in range(_notes.size()):
		if is_instance_valid(_notes[i]):
			var _note: Note = _notes[i]
			_note.update_beat(curr_beat)
	
	if EmbeddedGlobalSettings.enable_auto_input:
		_auto_process_note()
	_miss_old_notes()


func _on_note_hit(hit_type: Enums.Hit_Type) -> void:
	match hit_type:
		Enums.Hit_Type.PERFECT:
			play_stats.perfect_count += 1
			sfx_player.play()
		Enums.Hit_Type.CRITICAL:
			play_stats.critical_count += 1
			sfx_player.play()
		Enums.Hit_Type.GREAT:
			play_stats.great_count += 1
			sfx_player.play()
		Enums.Hit_Type.GOOD:
			play_stats.good_count += 1
			sfx_player.play()
		Enums.Hit_Type.BAD:
			play_stats.bad_count += 1
		Enums.Hit_Type.MISS:
			play_stats.miss_count += 1
	
	note_hit_type.emit(hit_type, note_final_position)


func _auto_process_note() -> void:
	if not _notes.is_empty():
		#var note := _notes[0] as Note
		if is_instance_valid(_notes.back()):
			var note: Note = _notes.back()
			var note_delta := _get_note_delta(note)
			
			if -Note.HIT_MARGIN_PERFECT <= note_delta and note_delta <= Note.HIT_MARGIN_PERFECT:
				if note is TapNote:
					var key: Key = AutoInputManager.get_unpressed_button()
					AutoInputManager.set_buttons_list(key, true)
					handle_press(key)
					AutoInputManager.set_buttons_list(key, false)
					handle_empty_release(key)
				elif note is LongNote:
					var key: Key = AutoInputManager.get_unpressed_button()
					AutoInputManager.set_buttons_list(key, true)
					handle_press(key)
				elif note is LongBackNote:
					AutoInputManager.set_buttons_list(held_key, false)
					handle_release(held_key)
				elif note is SlideNote:
					handle_slide(note.direction)
				elif note is DoubleSlideNote:
					handle_double_slide(note.direction_1, note.direction_2)
				elif note is LongSlideNote:
					handle_slide(note.direction)
				elif note is LongDoubleSlide:
					handle_double_slide(note.direction_1, note.direction_2)


func _miss_old_notes() -> void:
	while not _notes.is_empty():
		#var note := _notes[0] as Note
		if is_instance_valid(_notes.back()):
			var note: Note = _notes.back()
			var note_delta := _get_note_delta(note)
			
			if note_delta > Note.HIT_MARGIN_GOOD:
				# Time is past the note's hit window, miss.
				print("Miss old note %s at current beat %s note delta %s" % [note.beat, _get_curr_beat(), note_delta])
				
				
				if note is LongNote:
					note.miss(false)
					_notes.pop_back()
					
					var back_note_index = _notes.size() - 1
					
					if back_note_index == -1:
						continue
					var back_note = _notes[back_note_index]
					back_note.miss(false)
					_notes.remove_at(back_note_index)
				else:
					note.miss(false)
					_notes.pop_back()
				
				array_change.emit()
				#_play_stats.miss_count += 1
				#note_hit.emit(note.beat, Enums.HitType.MISS_LATE, note_delta)
			else:
				# Note is still hittable, so stop checking rest of the (later)
				# notes.
				break
		else:
			break


func _get_note_delta(note: Note) -> float:
	var curr_beat := _get_curr_beat()
	var beat_delta := curr_beat - note.beat
	
	return beat_delta * rhythm_game.conductor.get_beat_duration()


func _get_curr_beat() -> float:
	var curr_beat: float
	match time_type:
		Enums.TimeType.FILTERED:
			curr_beat = rhythm_game.conductor.get_current_beat()
		Enums.TimeType.RAW:
			curr_beat = rhythm_game.conductor.get_current_beat_raw()
		_:
			assert(false, "Unknown TimeType: %s" % time_type)
			curr_beat = rhythm_game.conductor.get_current_beat()
	
	# Adjust the timing for input delay. While this will shift the note
	# positions such that "on time" does not line up visually with the guide
	# sprite, the resulting visual is a lot smoother compared to readjusting the
	# note position after hitting it.
	curr_beat -= EmbeddedGlobalSettings.input_latency_ms / 1000.0 / rhythm_game.conductor.get_beat_duration()
	
	return curr_beat

func flush_notes() -> void:
	_beats.clear()
	_notes.clear()
	
	for child in get_children():
		child.queue_free()


func set_note_beats(param_array) -> void:
	_note_beats.append_array(param_array)
	_note_beats.sort()


func set_notes(beat: float, type: int, direction: int, direction_2: int) -> void:
	_beats[beat] = [type, direction, direction_2]
	_beats.sort()


func create_notes(y_offset: float) -> void:
	note_final_position.y = y_offset
	note_final_position.x = EmbeddedGlobalSettings.judgement_line
	
	for beat in _beats:
		
		var type = _beats[beat][0]
		var note: Note = null
		
		match type:
			Enums.Note_Type.TAP:
				note = NOTE_SCENE.instantiate() as TapNote
			Enums.Note_Type.SLIDE:
				note = SLIDE_NOTE_SCENE.instantiate() as SlideNote
				
				var direction =  _beats[beat][1]
				note.direction = direction as Enums.Direction
			Enums.Note_Type.DOUBLE_SLIDE:
				note = DOUBLE_SLIDE_NOTE_SCENE.instantiate() as DoubleSlideNote
				
				var direction =  _beats[beat][1]
				var direction_2 = _beats[beat][2]
				note.direction_1 = direction as Enums.Direction
				note.direction_2 = direction_2 as Enums.Direction
			Enums.Note_Type.LONG:
				var line: Line2D = LONG_NOTE_LINE.instantiate()
				
				note = LONG_NOTE_SCENE.instantiate() as LongNote
				add_child(line)
				
				note.line = line
				note.held = true
				
				_last_long_note = note
			Enums.Note_Type.LONG_BACK:
				note = LONG_BACK_NOTE_SCENE.instantiate() as LongBackNote
				
				_last_long_note.back_note = note
				note.line = _last_long_note.line
				note.held = true
			Enums.Note_Type.LONG_SLIDE:
				note = LONG_SLIDE_NOTE_SCENE.instantiate() as LongSlideNote
				
				var direction =  _beats[beat][1]
				note.direction = direction as Enums.Direction
				
				_last_long_note.back_note = note
				note.line = _last_long_note.line
				note.held = true
			Enums.Note_Type.LONG_DOUBLE_SLIDE:
				note = LONG_DOUBLE_SLIDE_NOTE_SCENE.instantiate() as LongDoubleSlide
				
				var direction =  _beats[beat][1]
				var direction_2 = _beats[beat][2]
				note.direction_1 = direction as Enums.Direction
				note.direction_2 = direction_2 as Enums.Direction
				
				_last_long_note.back_note = note
				note.line = _last_long_note.line
				note.held = true
		
		note.y_offset = y_offset
		note.beat = beat
		note.conductor = rhythm_game.conductor
		note.update_beat(-100)
		note.note_hit.connect(_on_note_hit)
		add_child(note)
		_notes.push_front(note)


func get_note_delta_of_first_note() -> float:
	if _notes.is_empty():
		return MAX_NOTE_DELTA
	
	if is_instance_valid(_notes.back()):
		var note: Note = _notes.back()
		
		var curr_beat := _get_curr_beat()
		var beat_delta := curr_beat - note.beat
		
		return beat_delta * rhythm_game.conductor.get_beat_duration()
	
	return MAX_NOTE_DELTA


func is_closest_note_long() -> bool:
	if _notes.is_empty():
		return false
	
	if not is_instance_valid(_notes.back()):
		return false
	
	var note: Note = _notes.back()
	
	return note is LongBackNote


func is_closest_note_tap() -> bool:
	if _notes.is_empty():
		return false
	
	if not is_instance_valid(_notes.back()):
		return false
	
	var note: Note = _notes.back()
	
	return note is TapNote


func closest_note() -> Note:
	if _notes.is_empty():
		return null
	
	return _notes.back()


func pop_back() -> void:
	var last_index = _notes.size() - 1
	
	_notes.remove_at(last_index)
	array_change.emit()


## Handles the note when a key has been pressed.
func handle_press(key: Key) -> bool:
	print("	HANDLE PRESS %s" % self)
	print("	Pressed Song time %s" % str(rhythm_game.conductor.get_song_time()))
	
	if _notes.is_empty():
		return false
	
	if not is_instance_valid(_notes.back()):
		pop_back()
		return false
	
	var note: Note = _notes.back()
	var hit_delta: float = _get_note_delta(note)
	
	print("	Current beat %s" % _get_curr_beat())
	print("	Note %s beat %s" % [note, note.beat])
	print("	Is long note %s" % [note is LongNote])
	
	if note is SlideNote or note is LongBackNote or note is LongSlideNote or note is LongDoubleSlide:
		return false
	
	if note is LongNote:
		held_key = key
		print("Held Key %s" % OS.get_keycode_string(held_key))
		if note.evaluate_long(hit_delta, key, held_key):
			
			if note.release_back:
				print("Remove back note")
			print("	Pressed LONG note beat %s %s held key %s" % [note.beat, hit_delta, OS.get_keycode_string(held_key)])
			pop_back()
			
			front_note_type = Enums.Note_Type.LONG
			previous_note_type.emit(self, front_note_type)
			
			return true
		else:
			return false
	
	if note is TapNote:
		if note.evaluate(hit_delta):
			print("	Pressed TAP note beat %s %s key %s" % [note.beat, hit_delta, OS.get_keycode_string(key)])
			pop_back()
			
			print(Enums.Note_Type.keys()[front_note_type])
			previous_key = key
			front_note_type = Enums.Note_Type.TAP
			previous_note_type.emit(self, front_note_type)
			
			return true
		else:
			return false
	else:
		return false


## Handles the note when a key has been released.
func handle_release(key: Key) -> bool:
	print("	HANDLE RELEASE")
	print("	Release Song time %s" % str(rhythm_game.conductor.get_song_time()))
	
	if _notes.is_empty():
		return false
	
	if not is_instance_valid(_notes.back()):
		pop_back()
		return false
	
	var note: Note = _notes.back()
	var hit_delta: float = _get_note_delta(note)
	
	print("	Current beat %s" % _get_curr_beat())
	print("	Note %s beat %s" % [note, note.beat])
	print("	note held %s and is longbacknote %s" % [note.held, (note is LongBackNote)])
	
	if note.held and note is LongBackNote:
		if note.evaluate_release(hit_delta, key, held_key):
			pop_back()
			print("	Pressed note beat %s %s" % [note.beat, hit_delta])
			
			front_note_type = Enums.Note_Type.LONG_BACK
			
			held_key = KEY_NONE
			previous_key = KEY_NONE
			
			previous_note_type.emit(self, front_note_type)
			return true
		else:
			return false
	elif note.held and note is LongSlideNote:
		if note.evaluate_release(hit_delta):
			return true
		else:
			return false
	else:
		return false


func handle_empty_release(key: Key) -> bool:
	print("	HANDLE EMPTY RELEASE %s NOTE MANAGER %s" % [OS.get_keycode_string(key), self])
	print("EMPTY RELEASE Previous Key %s" % OS.get_keycode_string(previous_key))
	if previous_key == key:
		print("Previous key == key %s" % OS.get_keycode_string(previous_key))
		
		previous_key = KEY_NONE
		front_note_type = Enums.Note_Type.NONE
		array_change.emit()
		return true
	
	elif previous_key == KEY_NONE:
		print("Previous key == KEY_NONE %s" % OS.get_keycode_string(previous_key))
		return false
	
	print("End of empty release Previous key %s" % OS.get_keycode_string(previous_key))
	return false


## Handles the note was a slide key has been pressed.
func handle_slide(direction: Enums.Direction) -> bool:
	print("	HANDLE SLIDE")
	print("Direction %s" % Enums.Direction.keys()[direction])
	
	if _notes.is_empty():
		return false
	
	if not is_instance_valid(_notes.back()):
		pop_back()
		return false
	
	var note: Note = _notes.back()
	var hit_delta: float = _get_note_delta(note)
	print("Evaluate at %s" % str(Time.get_ticks_usec() / 1000000.0))
	
	print("Is LongSlide %s" % [note is LongSlideNote])
	
	if note is SlideNote or note is LongSlideNote:
		if note.evaluate_slide(hit_delta, direction):
			print("	Pressed note beat %s %s" % [note.beat, hit_delta])
			pop_back()
			
			front_note_type = Enums.Note_Type.SLIDE
			previous_note_type.emit(self, front_note_type)
			
			return true
		else:
			print("	Not Ready to evaluate %s" % note.beat)
			
			return false
	else:
		return false


func handle_double_slide(direction_right: Enums.Direction, direction_left: Enums.Direction) -> bool:
	print("	HANDLE DOUBLE SLIDE")
	if _notes.is_empty():
		return false
	
	if not is_instance_valid(_notes.back()):
		pop_back()
		return false
	
	var note: Note = _notes.back()
	var hit_delta: float = _get_note_delta(note)
	print("Evaluate at %s" % str(Time.get_ticks_usec() / 1000000.0))
	
	if note is DoubleSlideNote or note is LongDoubleSlide:
		if note.evaluate_slide(hit_delta, direction_right, direction_left):
			print("	Pressed note beat %s %s" % [note.beat, hit_delta])
			pop_back()
			
			return true
		else:
			print("	Not Ready to evaluate %s" % note.beat)
			
			return false
	else:
		return false
