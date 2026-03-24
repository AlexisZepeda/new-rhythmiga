class_name InputSettings
extends Control


@export_category("Buttons")
@export_group("Tap")
@export var tap_1: ActionRemapButton
@export var tap_2: ActionRemapButton
@export var tap_3: ActionRemapButton
@export var tap_4: ActionRemapButton

@export_group("Slide")
@export var left_1: ActionRemapButton
@export var left_2: ActionRemapButton
@export var up_1: ActionRemapButton
@export var up_2: ActionRemapButton
@export var right_1: ActionRemapButton
@export var right_2: ActionRemapButton
@export var down_1: ActionRemapButton
@export var down_2: ActionRemapButton
@export_group("")

@export var apply: Button
@export var reset: Button

var action_button_children: Array = []


func _ready() -> void:
	apply.pressed.connect(_on_apply_pressed)
	reset.pressed.connect(_on_reset_pressed)
	
	action_button_children = [tap_1, tap_2, tap_3, tap_4, left_1, left_2, 
										up_1, up_2, right_1, right_2, down_1, down_2]


func _on_apply_pressed() -> void:
	KeyPersistence.save_keymap()


func _on_reset_pressed() -> void:
	print("Reset")
	for button: ActionRemapButton in action_button_children:
		button.reset()
