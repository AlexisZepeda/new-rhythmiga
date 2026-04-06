class_name InputToCommandManager
extends Resource

enum _Note_Manager_Dict_Keys { NOTE_MANAGER, NOTE_TYPE }

var tap_left_1: Key = KEY_E
var tap_left_2: Key = KEY_F
var tap_right_1: Key = KEY_I
var tap_right_2: Key = KEY_J


var last_four_tap_commands: Dictionary[Key, Command] = {
	tap_left_1: null,
	tap_left_2: null,
	tap_right_1: null,
	tap_right_2: null,
}

var keys_pressed_together: Dictionary[Key, bool] = {
	tap_left_1: false,
	tap_left_2: false,
	tap_right_1: false,
	tap_right_2: false,
}

var note_manager_dict: Dictionary[Key, Array] = {
	tap_left_1: [null, Enums.Note_Type.NONE],
	tap_left_2: [null, Enums.Note_Type.NONE],
	tap_right_1: [null, Enums.Note_Type.NONE],
	tap_right_2: [null, Enums.Note_Type.NONE],
}


## Update new [Key].
func set_dictionaries() -> void:
	last_four_tap_commands = {
		tap_left_1: null,
		tap_left_2: null,
		tap_right_1: null,
		tap_right_2: null,
	}
	
	keys_pressed_together = {
		tap_left_1: false,
		tap_left_2: false,
		tap_right_1: false,
		tap_right_2: false,
	}

	note_manager_dict = {
		tap_left_1: [null, Enums.Note_Type.NONE],
		tap_left_2: [null, Enums.Note_Type.NONE],
		tap_right_1: [null, Enums.Note_Type.NONE],
		tap_right_2: [null, Enums.Note_Type.NONE],
	}


## Adds a [Command] to the [member InputToCommandManager.keys_pressed_together] dictionary.
func pressed_together(command: Command) -> void:
	if command is not TapCommand:
		return
	
	for key in last_four_tap_commands:
		var tap_command: Command = last_four_tap_commands[key]
		
		if tap_command:
			if abs(tap_command.pressed - command.pressed) <= Note.HIT_MARGIN_BAD and tap_command.key != command.key:
				last_four_tap_commands[command.key] = command
				keys_pressed_together[command.key] = true
				keys_pressed_together[tap_command.key] = true
		else:
			if key == command.key:
				last_four_tap_commands[key] = command


func is_still_held(key: Key) -> bool:
	if key == KEY_NONE:
		return false
	
	return keys_pressed_together[key]


## Returns array of [enum Keys] excluding [member Command.key].
func get_keys_from_dictionaries(command: Command) -> Array[Key]:
	var result: Array[Key] = []
	
	for key in last_four_tap_commands:
		if key == command.key:
			continue
		
		var loop_command: Command = last_four_tap_commands[key]
		
		if loop_command and keys_pressed_together[key]:
			result.append(key)
	
	return result


func clear_command_from_dictionaries(command: Command) -> void:
	if command is TapReleaseCommand or command is ReleaseCommand:
		last_four_tap_commands[command.key] = null
	
		keys_pressed_together[command.key] = false


## Returns a [NoteManager] from the [member InputToCommandManager.note_manager_dict] which equals [enum Enums.Note_Type].s
func find_previous_tap(param_key: Key) -> NoteManager:
	for key in note_manager_dict:
		if note_manager_dict[key][_Note_Manager_Dict_Keys.NOTE_TYPE] == Enums.Note_Type.TAP and key == param_key:
			var result = note_manager_dict[key][_Note_Manager_Dict_Keys.NOTE_MANAGER]
			return result
	
	return null


func set_note_manager(key: Key, note_manager: NoteManager) -> void:
	note_manager_dict[key][_Note_Manager_Dict_Keys.NOTE_MANAGER] = note_manager


func get_note_manager(key: Key) -> NoteManager:
	var result: NoteManager = note_manager_dict[key][_Note_Manager_Dict_Keys.NOTE_MANAGER]
	
	if is_instance_valid(result):
		return result
	else:
		return null


func set_note_type(key: Key, note_type: Enums.Note_Type) -> void:
	note_manager_dict[key][_Note_Manager_Dict_Keys.NOTE_TYPE] = note_type


func get_note_type(key: Key) -> Enums.Note_Type:
	var result: Enums.Note_Type = note_manager_dict[key][_Note_Manager_Dict_Keys.NOTE_TYPE]
	return result


func remove_from_note_manager_dict(note_manger: NoteManager) -> void:
	for key in note_manager_dict:
		if note_manager_dict[key][_Note_Manager_Dict_Keys.NOTE_MANAGER] == note_manger:
			note_manager_dict[key][_Note_Manager_Dict_Keys.NOTE_MANAGER] = null
			
			break
