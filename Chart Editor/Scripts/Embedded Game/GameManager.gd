class_name GameManager
extends Node2D

@export var debug_ui: Control
@export var input_to_command_manager: Resource

var input_buffer: Array[Command] = []

var lane_queue: PriorityQueue


func _process(_delta: float) -> void:
	if not input_buffer.is_empty():
		var command: Command = input_buffer.back()
		var lane: LinkedNode = lane_queue.get_front()
		
		if process_input(command, lane):
			input_to_command_manager.clear_command_from_dictionaries(command)
			
			input_buffer.pop_back()
		else:
			if command.is_stale(Time.get_ticks_usec() / 1000000.0):
				print("		Command is stale remove")
				input_to_command_manager.clear_command_from_dictionaries(command)
				
				input_buffer.pop_back()
			else:
				input_buffer.push_front(input_buffer.pop_back())
	
	debug_ui.print_keys(input_to_command_manager.is_still_held(KEY_E), input_to_command_manager.is_still_held(KEY_F), input_to_command_manager.is_still_held(KEY_I), input_to_command_manager.is_still_held(KEY_J))


## Adds command to the input buffer array.
func _on_rhythm_game_input_manager_command_emitted(command: Command) -> void:
	input_buffer.push_front(command)
	input_to_command_manager.pressed_together(command)
	input_to_command_manager.clear_command_from_dictionaries(command)


func _on_previous_note_type(note_manager: NoteManager, note_type: Enums.Note_Type) -> void:
	if note_manager.held_key != KEY_NONE:
		input_to_command_manager.set_note_manager(note_manager.held_key, note_manager)
		input_to_command_manager.set_note_type(note_manager.held_key, note_type)
	elif note_manager.previous_key != KEY_NONE:
		input_to_command_manager.set_note_manager(note_manager.previous_key, note_manager)
		input_to_command_manager.set_note_type(note_manager.previous_key, note_type)


## Removes [param command] and replaces it with [param new_command] in the [member input_buffer].
func _replace_command_in_input_buffer(command: Command, new_command: Command) -> void:
	if input_buffer.has(command) and input_buffer.back() == command:
		command = new_command
		input_buffer.pop_back()
		input_buffer.push_back(command)


## Process the first command in the input buffer. Returns true if the command successfully executed.
func process_input(command: Command, lane: LinkedNode) -> bool:
	print("			START PROCESS INPUT %s" % [OS.get_keycode_string(command.key)])
	if command is SlideCommand:
		print("			DIRECTION %s" % Enums.Direction.keys()[command.direction])
	elif command is DoubleSlideCommand:
		print("			DIRECTIONS RIGHT %s LEFT %s" % [Enums.Direction.keys()[command.direction_axis_right], Enums.Direction.keys()[command.direction_axis_left]])
	
	if not is_instance_valid(lane):
		return false
	
	var note_manager: NoteManager = lane.value
	
	if command is TapReleaseCommand or command is ReleaseCommand:
		
		var active_keys: Array[Key] = input_to_command_manager.get_keys_from_dictionaries(command)
		# Check if other keys were pressed at the same time
		if active_keys.size() >= 1:
			
			if lane_queue.has_held_key(command.key):
				
				lane = lane_queue.has_held_key(command.key)
			
			var _note_manager: NoteManager = lane.value
		
			var _previous_tap: NoteManager = input_to_command_manager.find_previous_tap(command.key)
			
			# Note manager's key is released but needs to still be held
			if _note_manager.held_key == command.key and _note_manager.get_note_delta_of_first_note() < -Note.HIT_MARGIN_MISS:
				if active_keys.has(note_manager.held_key):
					_note_manager.held_key = note_manager.held_key
					note_manager.held_key = command.key
				else:
					_note_manager.held_key = active_keys.front()
					
				
				if is_instance_valid(_previous_tap):
					if _previous_tap.previous_key == _note_manager.held_key:
						_previous_tap.previous_key = command.key
						
						var new_command: ReleaseCommand = ReleaseCommand.new(command.pressed)
						new_command.key = command.key
						
						_replace_command_in_input_buffer(command, new_command)
						
						input_to_command_manager.remove_from_note_manager_dict(_previous_tap)
						
				return false
		
			if _note_manager.is_closest_note_long() and not input_to_command_manager.is_still_held(_note_manager.held_key):
				_note_manager.held_key = command.key
			
			
		else:
			# If a NoteManager has command.key, override lane with returned LinkedNode
			if lane_queue.has_held_key(command.key):
				lane = lane_queue.has_held_key(command.key)
			else:
				var _note_manager: NoteManager = lane.value
				
				if _note_manager.is_closest_note_long():
					_note_manager.held_key = command.key
	
	if command is ReleaseCommand:
		var _lane: LinkedNode = lane_queue.has_previous_key(command.key)
		if _lane != null:
			print("		PROCESS RELEASECOMMAND")
			print("		Note manager %s" % _lane.value)
			lane = _lane
	
	
	if lane == null:
		return false
	
	note_manager = lane.value
	
	print("		PROCESS WITH %s" % note_manager)
	
	if command.execute(note_manager):
		lane_queue.remove(lane)
		return true
	else:
		return false
