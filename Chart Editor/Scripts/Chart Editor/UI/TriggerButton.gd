class_name TriggerButton
extends TextureButton


func set_toggled() -> void:
	if button_pressed:
		set_modulate(Color(1, 1, 1, 0.5))


func set_untoggled() -> void:
	if not button_pressed:
		set_modulate(Color(1, 1, 1, 1))
