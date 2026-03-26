class_name ChartEditorInputManager
extends Node


@export var chart_editor: ChartEditor
@export var conductor: ChartConductor

static var save_shortcut: Shortcut = Shortcut.new()

static var is_paused: bool = true


func _ready() -> void:
	var key_event = InputEventKey.new()
	key_event.keycode = KEY_S
	key_event.ctrl_pressed = true
	key_event.command_or_control_autoremap = true # Swaps Ctrl for Command on Mac.
	save_shortcut.events = [key_event]


func _input(event: InputEvent) -> void:
	if is_paused:
		return
	
	if save_shortcut.matches_event(event) and event.is_pressed() and not event.is_echo():
		print("Save shortcut pressed!")
		get_viewport().set_input_as_handled()
		
		chart_editor._on_save_pressed()
	
	if Input.is_action_just_pressed("ui_select"):
		print(conductor.is_paused)
		
		if not conductor.is_paused:
			conductor.play_conductor(0.0)
		else:
			conductor.pause_conductor()
		
		get_viewport().set_input_as_handled()
