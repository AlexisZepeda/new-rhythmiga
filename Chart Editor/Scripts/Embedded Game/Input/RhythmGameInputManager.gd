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
	print("Right axis %s" % _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_RIGHT))
	print("Left axis %s" % _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_LEFT))
	
	if _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_RIGHT) and _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_LEFT):
		print("Double input")
		
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


func _create_slide_command(vector: Vector2, axis: Enums.Joy_Axis) -> Command:
	var direction: Enums.Direction = Utils.get_direction(vector)
	_set_joy_axis_list(axis, true, direction)
	return SlideCommand.new((Time.get_ticks_usec() / 1000000.0), direction)


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
	## RELEASE
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
		
		
		# Is event a Slide Action
	## AXIS LEFT
	if (Input.is_action_just_pressed("Down Slide Left Joy") or Input.is_action_just_pressed("Up Slide Left Joy")
		or Input.is_action_just_pressed("Left Slide Left Joy") or Input.is_action_just_pressed("Right Slide Left Joy")):
		#if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_LEFT):
			var vector: Vector2 = Input.get_vector("Left Slide Left Joy", "Right Slide Left Joy", "Up Slide Left Joy", "Down Slide Left Joy")
			return _create_slide_command(vector, Enums.Joy_Axis.JOY_AXIS_LEFT)
	## AXIS RIGHT
	if (Input.is_action_just_pressed("Down Slide Right Joy") or Input.is_action_just_pressed("Up Slide Right Joy")
		or Input.is_action_just_pressed("Left Slide Right Joy") or Input.is_action_just_pressed("Right Slide Right Joy")):
		#if not _joy_axis_pressed(Enums.Joy_Axis.JOY_AXIS_LEFT):
			var vector: Vector2 = Input.get_vector("Left Slide Right Joy", "Right Slide Right Joy", "Up Slide Right Joy", "Down Slide Right Joy")
			return _create_slide_command(vector, Enums.Joy_Axis.JOY_AXIS_RIGHT)
	
	## AXIS LEFT RELEASE
	if (Input.is_action_just_released("Down Slide Left Joy") or Input.is_action_just_released("Up Slide Left Joy")
		or Input.is_action_just_released("Left Slide Left Joy") or Input.is_action_just_released("Right Slide Left Joy")):
		var vector: Vector2 = Input.get_vector("Left Slide Left Joy", "Right Slide Left Joy", "Up Slide Left Joy", "Down Slide Left Joy")
		var direction: Enums.Direction = Utils.get_direction(vector)
		_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_LEFT, false, direction)
	
	## AXIS RIGHT RELEASE
	if (Input.is_action_just_released("Down Slide Right Joy") or Input.is_action_just_released("Up Slide Right Joy")
		or Input.is_action_just_released("Left Slide Right Joy") or Input.is_action_just_released("Right Slide Right Joy")):
		var vector: Vector2 = Input.get_vector("Left Slide Right Joy", "Right Slide Right Joy", "Up Slide Right Joy", "Down Slide Right Joy")
		var direction: Enums.Direction = Utils.get_direction(vector)
		_set_joy_axis_list(Enums.Joy_Axis.JOY_AXIS_RIGHT, false, direction)
	
	return null
