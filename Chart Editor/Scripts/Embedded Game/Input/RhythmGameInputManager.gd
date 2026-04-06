class_name RhythmGameInputManager
extends Node

signal command_emitted(command: Command)

enum Joy_Axis_Label { PRESSED, DIRECTION }
enum Buttons_Label { PRESSED = 0, RELEASED = 1 }

const PRESSED_AT_SAME_TIME_MARGIN = Note.HIT_MARGIN_BAD

@export var input_to_command_manager: InputToCommandManager

var tap_left_1: Key = InputMap.action_get_events("Tap Left 1")[0].keycode
var tap_left_2: Key = InputMap.action_get_events("Tap Left 2")[0].keycode
var tap_right_1: Key = InputMap.action_get_events("Tap Right 1")[0].keycode
var tap_right_2: Key = InputMap.action_get_events("Tap Right 2")[0].keycode

var JOY_AXIS_LIST: Dictionary = {
	Enums.Joy_Axis.JOY_AXIS_RIGHT: {
		Joy_Axis_Label.PRESSED: false,
		Joy_Axis_Label.DIRECTION: Enums.Direction.UP
	},
	Enums.Joy_Axis.JOY_AXIS_LEFT: {
		Joy_Axis_Label.PRESSED: false,
		Joy_Axis_Label.DIRECTION: Enums.Direction.UP
	},
}

var BUTTONS_LIST: Dictionary = {
	tap_left_1: false,
	tap_left_2: false,
	tap_right_1: false,
	tap_right_2: false,
}

var BUTTONS_LONG_PRESSED: Dictionary = {
	tap_left_1: [0.0, 0.0],
	tap_left_2: [0.0, 0.0],
	tap_right_1: [0.0, 0.0],
	tap_right_2: [0.0, 0.0],
}


var held_time_e: float = 0.0
var held_time_f: float = 0.0
var held_time_i: float = 0.0
var held_time_j: float = 0.0


func _ready() -> void:
	#print(InputMap.action_get_events("Tap Left 1")[0].keycode)
	#
	#tap_left_1 = InputMap.action_get_events("Tap Left 1")[0].keycode
	#tap_left_2 = InputMap.action_get_events("Tap Left 2")[0].keycode
	#tap_right_1 = InputMap.action_get_events("Tap Right 1")[0].keycode
	#tap_right_2 = InputMap.action_get_events("Tap Right 2")[0].keycode
	
	input_to_command_manager.tap_left_1 = tap_left_1
	input_to_command_manager.tap_left_2 = tap_left_2
	input_to_command_manager.tap_right_1 = tap_right_1
	input_to_command_manager.tap_right_2 = tap_right_2
	
	input_to_command_manager.set_dictionaries()


func _unhandled_input(event: InputEvent) -> void:
	if not EmbeddedGlobalSettings.enable_input:
		return
	
	var command: Command = handle_input(event)
	command = _change_release_commands(command)
	
	# Check for double input
	if _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_RIGHT) and _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_LEFT):
		#print("Double input")
		
		var axis_right_direction: Enums.Direction = JOY_AXIS_LIST[Enums.Joy_Axis.JOY_AXIS_RIGHT][Joy_Axis_Label.DIRECTION]
		var axis_left_direction: Enums.Direction = JOY_AXIS_LIST[Enums.Joy_Axis.JOY_AXIS_LEFT][Joy_Axis_Label.DIRECTION]
		
		command = DoubleSlideCommand.new((Time.get_ticks_usec() / 1000000.0), axis_right_direction, axis_left_direction)
	
	if command:
		command_emitted.emit(command)
		#print("Event %s" % OS.get_keycode_string(event.keycode))


# Dictionary helper functions
func _set_joy_axis_list(axis: Enums.Joy_Axis, pressed: bool, direction: Enums.Direction) -> void:
	JOY_AXIS_LIST[axis][Joy_Axis_Label.PRESSED] = pressed
	JOY_AXIS_LIST[axis][Joy_Axis_Label.DIRECTION] = direction


func _joy_axis_pressed(axis: Enums.Joy_Axis) -> bool:
	return JOY_AXIS_LIST[axis][Joy_Axis_Label.PRESSED]


func _set_buttons_list(key: Key, pressed: bool) -> void:
	BUTTONS_LIST[key] = pressed


func _button_is_pressed(key: Key) -> bool:
	return BUTTONS_LIST[key]


func _change_release_commands(command: Command) -> Command:
	if command is TapReleaseCommand:
		var _note_manager: NoteManager = input_to_command_manager.get_note_manager(command.key)
		var _note_type: Enums.Note_Type = input_to_command_manager.get_note_type(command.key)
		
		if _note_manager == input_to_command_manager.find_previous_tap(command.key):
			var new_command: ReleaseCommand = ReleaseCommand.new(command.pressed)
			new_command.key = command.key
			 
			command = new_command
		elif _note_type == Enums.Note_Type.TAP:
			var new_command: ReleaseCommand = ReleaseCommand.new(command.pressed)
			new_command.key = command.key
			 
			command = new_command
	
	elif command is ReleaseCommand:
		var _note_manager: NoteManager = input_to_command_manager.get_note_manager(command.key)
		var _note_type: Enums.Note_Type = input_to_command_manager.get_note_type(command.key)
		
		if _note_type == Enums.Note_Type.LONG:
			var new_command: TapReleaseCommand = TapReleaseCommand.new(command.pressed)
			new_command.key = command.key
			 
			command = new_command
	
	return command


func _create_tap_command(key: Key) -> Command:
	_set_buttons_list(key, true)
	var tap_command: TapCommand = TapCommand.new(Time.get_ticks_usec() / 1000000.0)
	tap_command.set_key(key)
	BUTTONS_LONG_PRESSED[key][Buttons_Label.PRESSED] = tap_command.pressed
	
	print("Button %s pressed at %s" % [OS.get_keycode_string(tap_command.key), tap_command.pressed])
	
	return tap_command


## Returns [TapReleaseCommand] if [enum Global.Key] was pressed for longer than [member EmbeddedGlobalSettings.sixteenth_duration],
## else returns [ReleaseCommand].
func _create_tap_release_command(key: Key) -> Command:
	_set_buttons_list(key, false)
	var _time_created: float = Time.get_ticks_usec() / 1000000.0
	var tap_release_command: TapReleaseCommand = TapReleaseCommand.new(_time_created)
	
	BUTTONS_LONG_PRESSED[key][Buttons_Label.RELEASED] = tap_release_command.pressed
	tap_release_command.set_key(key)
	
	if abs(BUTTONS_LONG_PRESSED[key][Buttons_Label.RELEASED] - BUTTONS_LONG_PRESSED[key][Buttons_Label.PRESSED]) <= EmbeddedGlobalSettings.sixteenth_duration:
		var _release_command: ReleaseCommand = ReleaseCommand.new(_time_created)
		_release_command.set_key(key)
		return _release_command
	
	print("Button %s released at %s" % [OS.get_keycode_string(tap_release_command.key), tap_release_command.pressed])
	
	return tap_release_command


func handle_input(event: InputEvent) -> Command:
	if event is not InputEventKey:
		return null
	
	#if event is InputEventKey:
	if event.is_pressed():
		# Is event a Tap Action
		if InputMap.event_is_action(event, "Tap Right 1"):
			if not _button_is_pressed(event.keycode):
				return _create_tap_command(event.keycode)
		elif InputMap.event_is_action(event, "Tap Right 2"):
			if not _button_is_pressed(event.keycode):
				return _create_tap_command(event.keycode)
		elif InputMap.event_is_action(event, "Tap Left 1"):
			if not _button_is_pressed(event.keycode):
				return _create_tap_command(event.keycode)
		elif InputMap.event_is_action(event, "Tap Left 2"):
			if not _button_is_pressed(event.keycode):
				return _create_tap_command(event.keycode)
		
		# Is event a Slide Action
		## AXIS LEFT
		if InputMap.event_is_action(event, "Up Slide Left Joy"):
			if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_LEFT):
				_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, true, Enums.Direction.UP)
				return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.UP)
		elif InputMap.event_is_action(event, "Left Slide Left Joy"):
			if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_LEFT):
				_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, true, Enums.Direction.LEFT)
				return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.LEFT)
		elif InputMap.event_is_action(event, "Down Slide Left Joy"):
			if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_LEFT):
				_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, true, Enums.Direction.DOWN)
				return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.DOWN)
		elif InputMap.event_is_action(event, "Right Slide Left Joy"):
				if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_LEFT):
					_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, true, Enums.Direction.RIGHT)
					return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.RIGHT)
		## AXIS RIGHT
		elif InputMap.event_is_action(event, "Up Slide Right Joy"):
			if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_RIGHT):
				_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, true, Enums.Direction.UP)
				return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.UP)
		elif InputMap.event_is_action(event, "Left Slide Right Joy"):
			if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_RIGHT):
				_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, true, Enums.Direction.LEFT)
				return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.LEFT)
		elif InputMap.event_is_action(event, "Down Slide Right Joy"):
			if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_RIGHT):
				_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, true, Enums.Direction.DOWN)
				return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.DOWN)
		elif InputMap.event_is_action(event, "Right Slide Right Joy"):
			if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_RIGHT):
				_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, true, Enums.Direction.RIGHT)
				return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.RIGHT)
		
		#match event.keycode:
			## Tap Buttons
			#KEY_E:
				#if not _button_is_pressed(KEY_E):
					#return _create_tap_command(KEY_E)
				##return button_e
			#KEY_F:
				#if not _button_is_pressed(KEY_F):
					#return _create_tap_command(KEY_F)
				##return button_f
			#KEY_I:
				#if not _button_is_pressed(KEY_I):
					#return _create_tap_command(KEY_I)
				##return button_i
			#KEY_J:
				#if not _button_is_pressed(KEY_J):
					#return _create_tap_command(KEY_J)
				##return button_j
			## Slide Buttons
			## AXIS LEFT
			#KEY_W:
				#if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_LEFT):
					#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, true, Enums.Direction.UP)
					#return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.UP)
					##return button_w
			#KEY_A:
				#if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_LEFT):
					#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, true, Enums.Direction.LEFT)
					#return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.LEFT)
					##return button_a
			#KEY_S:
				#if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_LEFT):
					#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, true, Enums.Direction.DOWN)
					#return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.DOWN)
					##return button_s
			#KEY_D:
				#if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_LEFT):
					#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, true, Enums.Direction.RIGHT)
					#return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.RIGHT)
					##return button_d
			## AXIS RIGHT
			#KEY_O:
				#if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_RIGHT):
					#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, true, Enums.Direction.UP)
					#return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.UP)
					##return button_o
			#KEY_K:
				#if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_RIGHT):
					#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, true, Enums.Direction.LEFT)
					#return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.LEFT)
					##return button_k
			#KEY_L:
				#if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_RIGHT):
					#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, true, Enums.Direction.DOWN)
					#return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.DOWN)
					##return button_l
			#KEY_SEMICOLON:
				#if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_RIGHT):
					#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, true, Enums.Direction.RIGHT)
					#return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), Enums.Direction.RIGHT)
					##return button_semi_colon
	else:
		if InputMap.event_is_action(event, "Tap Right 1"):
				held_time_e = BUTTONS_LONG_PRESSED[event.keycode][Buttons_Label.RELEASED] - BUTTONS_LONG_PRESSED[event.keycode][Buttons_Label.PRESSED]
				return _create_tap_release_command(event.keycode)
		elif InputMap.event_is_action(event, "Tap Right 2"):
				held_time_e = BUTTONS_LONG_PRESSED[event.keycode][Buttons_Label.RELEASED] - BUTTONS_LONG_PRESSED[event.keycode][Buttons_Label.PRESSED]
				return _create_tap_release_command(event.keycode)
		elif InputMap.event_is_action(event, "Tap Left 1"):
				held_time_e = BUTTONS_LONG_PRESSED[event.keycode][Buttons_Label.RELEASED] - BUTTONS_LONG_PRESSED[event.keycode][Buttons_Label.PRESSED]
				return _create_tap_release_command(event.keycode)
		elif InputMap.event_is_action(event, "Tap Left 2"):
				held_time_e = BUTTONS_LONG_PRESSED[event.keycode][Buttons_Label.RELEASED] - BUTTONS_LONG_PRESSED[event.keycode][Buttons_Label.PRESSED]
				return _create_tap_release_command(event.keycode)
		## AXIS LEFT
		if InputMap.event_is_action(event, "Up Slide Left Joy"):
			_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, false, Enums.Direction.UP)
		elif InputMap.event_is_action(event, "Left Slide Left Joy"):
			_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, false, Enums.Direction.LEFT)
		elif InputMap.event_is_action(event, "Down Slide Left Joy"):
			_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, false, Enums.Direction.DOWN)
		elif InputMap.event_is_action(event, "Right Slide Left Joy"):
				_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, false, Enums.Direction.RIGHT)
		## AXIS RIGHT
		elif InputMap.event_is_action(event, "Up Slide Right Joy"):
			_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, false, Enums.Direction.UP)
		elif InputMap.event_is_action(event, "Left Slide Right Joy"):
			_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, false, Enums.Direction.LEFT)
		elif InputMap.event_is_action(event, "Down Slide Right Joy"):
			_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, false, Enums.Direction.DOWN)
		elif InputMap.event_is_action(event, "Right Slide Right Joy"):
			_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, false, Enums.Direction.RIGHT)
		#match event.keycode:
			#KEY_E:
				#held_time_e = BUTTONS_LONG_PRESSED[KEY_E][Buttons_Label.RELEASED] - BUTTONS_LONG_PRESSED[KEY_E][Buttons_Label.PRESSED]
				#return _create_tap_release_command(KEY_E)
				##return button_e_release
			#KEY_F:
				#held_time_f = BUTTONS_LONG_PRESSED[KEY_F][Buttons_Label.RELEASED] - BUTTONS_LONG_PRESSED[KEY_F][Buttons_Label.PRESSED]
				#return _create_tap_release_command(KEY_F)
				##return button_f_release
			#KEY_I:
				#held_time_i = BUTTONS_LONG_PRESSED[KEY_I][Buttons_Label.RELEASED] - BUTTONS_LONG_PRESSED[KEY_I][Buttons_Label.PRESSED]
				#return _create_tap_release_command(KEY_I)
				##return button_i_release
			#KEY_J:
				#held_time_j = BUTTONS_LONG_PRESSED[KEY_J][Buttons_Label.RELEASED] - BUTTONS_LONG_PRESSED[KEY_J][Buttons_Label.PRESSED]
				#return _create_tap_release_command(KEY_J)
				##return button_j_release
			## Slide Buttons
			## AXIS LEFT
			#KEY_W:
				#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, false, Enums.Direction.UP)
				##return null
			#KEY_A:
				#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, false, Enums.Direction.LEFT)
				##return null
			#KEY_S:
				#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, false, Enums.Direction.DOWN)
				##return null
			#KEY_D:
				#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, false, Enums.Direction.RIGHT)
				##return null
			## AXIS RIGHT
			#KEY_O:
				#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, false, Enums.Direction.UP)
				##return null
			#KEY_K:
				#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, false, Enums.Direction.LEFT)
				##return null
			#KEY_L:
				#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, false, Enums.Direction.DOWN)
				##return null
			#KEY_SEMICOLON:
				#_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, false, Enums.Direction.RIGHT)
				##return null
	#else:
		#return null
	
	return null
