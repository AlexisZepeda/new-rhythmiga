extends GridContainer

signal tap_toggled(toggled_on: bool)
signal arrow_toggled(toggled_on: bool)
signal double_arrow_toggled(toggled_on: bool)
signal long_toggled(toggled_on: bool)
signal long_arrow_toggled(toggled_on: bool)
signal long_double_arrow_toggled(toggled_on: bool)


@export_category("Buttons")
@export var tap_trigger_button: TriggerButton
@export var slide_trigger_button: TriggerButton
@export var double_slide_trigger_button: TriggerButton
@export var hold_trigger_button: TriggerButton
@export var hold_slide_trigger_button: TriggerButton
@export var hold_double_slide_trigger_button: TriggerButton

var buttons: Array[TriggerButton] = []


func _ready() -> void:
	buttons = [tap_trigger_button, slide_trigger_button, double_slide_trigger_button,
					hold_trigger_button, hold_slide_trigger_button, hold_double_slide_trigger_button]


func _set_button_pressed(button_to_skip: BaseButton, pressed: bool) -> void:
	for button: TriggerButton in buttons:
		if button == button_to_skip:
			continue
		else:
			button.button_pressed = pressed
			button.set_untoggled()


func _on_tap_toggled(toggled_on: bool) -> void:
	if toggled_on:
		tap_trigger_button.set_toggled()
		_set_button_pressed(tap_trigger_button, false)
	else:
		tap_trigger_button.set_untoggled()
	
	tap_toggled.emit(toggled_on)


func _on_slide_toggled(toggled_on: bool) -> void:
	if toggled_on:
		slide_trigger_button.set_toggled()
		_set_button_pressed(slide_trigger_button, false)
	else:
		slide_trigger_button.set_untoggled()
	
	arrow_toggled.emit(toggled_on)


func _on_double_slide_toggled(toggled_on: bool) -> void:
	
	
	if toggled_on:
		double_slide_trigger_button.set_toggled()
		_set_button_pressed(double_slide_trigger_button, false)
	else:
		double_slide_trigger_button.set_untoggled()
	
	double_arrow_toggled.emit(toggled_on)


func _on_hold_toggled(toggled_on: bool) -> void:
	
	
	if toggled_on:
		hold_trigger_button.set_toggled()
		_set_button_pressed(hold_trigger_button, false)
	else:
		hold_trigger_button.set_untoggled()
	
	long_toggled.emit(toggled_on)


func _on_hold_slide_toggled(toggled_on: bool) -> void:
	
	
	if toggled_on:
		hold_slide_trigger_button.set_toggled()
		_set_button_pressed(hold_slide_trigger_button, false)
	else:
		hold_slide_trigger_button.set_untoggled()
	
	long_arrow_toggled.emit(toggled_on)


func _on_hold_double_slide_toggled(toggled_on: bool) -> void:
	
	
	if toggled_on:
		hold_double_slide_trigger_button.set_toggled()
		_set_button_pressed(hold_double_slide_trigger_button, false)
	else:
		hold_double_slide_trigger_button.set_untoggled()
	
	long_double_arrow_toggled.emit(toggled_on)
	
