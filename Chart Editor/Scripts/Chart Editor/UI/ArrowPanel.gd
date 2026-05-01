class_name ArrowsPanel
extends PanelContainer

signal Toggled(index: int)
signal Untoggled

enum Slide_State { 
	NONE,
	SINGLE,
	DOUBLE,
}

@export_category("Buttons")
@export var up: ArrowPanelButton
@export var left: ArrowPanelButton
@export var right: ArrowPanelButton
@export var down: ArrowPanelButton
@export var up_left: ArrowPanelButton
@export var up_right: ArrowPanelButton
@export var down_left: ArrowPanelButton
@export var down_right: ArrowPanelButton

@export_category("Textures")
@export var slide_texture: Texture2D
@export var long_slide_texture: Texture2D


var _state: Slide_State = Slide_State.SINGLE
var buttons: Array[Button] = []

var toggled_button: Button = null


func _ready() -> void:
	buttons = [up, left, right, down, up_right, up_left, down_right, down_left]
	disable_buttons(true)
	_set_pivot_offset()


func _on_up_toggled(toggled_on: bool) -> void:
	if toggled_on and _is_single_slide():
		_set_button_pressed(up, false)
		
		toggled_button = up
		
		Toggled.emit(GlobalSettings.Directions.UP)
	else:
		Untoggled.emit()
	#print("Toggled Up %s" % toggled_on)


func _on_left_toggled(toggled_on: bool) -> void:
	if toggled_on and _is_single_slide():
		_set_button_pressed(left, false)
		
		toggled_button = left
		
		Toggled.emit(GlobalSettings.Directions.LEFT)
	else:
		Untoggled.emit()
	#print("Toggled Left %s" % toggled_on)


func _on_right_toggled(toggled_on: bool) -> void:
	if toggled_on and _is_single_slide():
		_set_button_pressed(right, false)
		
		toggled_button = right
		
		Toggled.emit(GlobalSettings.Directions.RIGHT)
	else:
		Untoggled.emit()
	#print("Toggled Right %s" % toggled_on)


func _on_down_toggled(toggled_on: bool) -> void:
	if toggled_on and _is_single_slide():
		_set_button_pressed(down, false)
		
		toggled_button = down
		
		Toggled.emit(GlobalSettings.Directions.DOWN)
	else:
		Untoggled.emit()
	#print("Toggled Down %s" % toggled_on)


func _on_down_right_toggled(toggled_on: bool) -> void:
	if toggled_on and _is_single_slide():
		_set_button_pressed(down_right, false)
		
		toggled_button = down_right
		
		Toggled.emit(GlobalSettings.Directions.DOWN_RIGHT)
	else:
		Untoggled.emit()


func _on_down_left_toggled(toggled_on: bool) -> void:
	if toggled_on and _is_single_slide():
		_set_button_pressed(down_left, false)
		
		toggled_button = down_left
		
		Toggled.emit(GlobalSettings.Directions.DOWN_LEFT)
	else:
		Untoggled.emit()


func _on_up_right_toggled(toggled_on: bool) -> void:
	if toggled_on and _is_single_slide():
		_set_button_pressed(up_right, false)
		
		toggled_button = up_right
		
		Toggled.emit(GlobalSettings.Directions.UP_RIGHT)
	else:
		Untoggled.emit()


func _on_up_left_toggled(toggled_on: bool) -> void:
	if toggled_on and _is_single_slide():
		_set_button_pressed(up_left, false)
		
		toggled_button = up_left
		
		Toggled.emit(GlobalSettings.Directions.UP_LEFT)
	else:
		Untoggled.emit()

func _is_single_slide() -> bool:
	return _state == Slide_State.SINGLE


func _is_double_slide() -> bool:
	return _state == Slide_State.DOUBLE


func _set_button_pressed(button_to_skip: Button, pressed: bool) -> void:
	for button: Button in buttons:
		if button == button_to_skip:
			continue
		else:
			button.button_pressed = pressed


func _set_pivot_offset() -> void:
	for button: Button in buttons:
		button.set_texture_pivot_offset()
	
	left.arrow_texture.rotation_degrees = 270
	right.arrow_texture.rotation_degrees = 90
	down.arrow_texture.rotation_degrees = 180
	up_left.arrow_texture.rotation_degrees = 315
	up_right.arrow_texture.rotation_degrees = 45
	down_left.arrow_texture.rotation_degrees = 225
	down_right.arrow_texture.rotation_degrees = 135


func set_button_texture() -> void:
	for button: Button in buttons:
		button.icon = slide_texture


func disable_buttons(disabled: bool) -> void:
	for button: Button in buttons:
		button.disabled = disabled
		if disabled:
			button.dim_texture()
		else:
			button.lighten_texture()


func set_arrows_state() -> void:
	_state = Slide_State.SINGLE


func set_slide_texture() -> void:
	for button: Button in buttons:
		button.load_slide_texture()


func set_long_slide_texture() -> void:
	for button: Button in buttons:
		button.load_long_slide_texture()
