class_name NoteCheckBoxes
extends CenterContainer

signal ARROW_DIRECTION_SELECTION(direction: GlobalSettings.Directions)
signal ARROW_2_DIRECTION_SELECTION(direction: GlobalSettings.Directions)
signal LONG_RELEASE_SELECTION(toggled_on: bool)

@export var arrows_panel: ArrowsPanel
@export var arrows_panel_2: ArrowsPanel

var arrow_direction: GlobalSettings.Directions

var long_arrow_pressed: bool = false
var long_double_arrow_pressed: bool = false


func _on_arrow_toggled(toggled_on: bool) -> void:
	if toggled_on:
		arrows_panel.disable_buttons(false)
		arrows_panel.set_slide_texture()
		arrows_panel_2.set_slide_texture()
	else:
		arrows_panel.disable_buttons(true)


func _on_double_arrow_toggled(toggled_on: bool) -> void:
	if toggled_on:
		arrows_panel.disable_buttons(false)
		arrows_panel_2.disable_buttons(false)
		arrows_panel.set_slide_texture()
		arrows_panel_2.set_slide_texture()

	else:
		arrows_panel.disable_buttons(true)
		arrows_panel_2.disable_buttons(true)


func _on_long_toggled(toggled_on: bool) -> void:
	if toggled_on:
		arrows_panel.set_long_slide_texture()
		arrows_panel_2.set_long_slide_texture()


func _on_long_arrow_toggled(toggled_on: bool) -> void:
	if toggled_on:
		arrows_panel.disable_buttons(false)
		arrows_panel.set_long_slide_texture()
		arrows_panel_2.set_long_slide_texture()
	else:
		arrows_panel.disable_buttons(true)
		LONG_RELEASE_SELECTION.emit(false)
	
	long_arrow_pressed = toggled_on


func _on_long_double_arrow_toggled(toggled_on: bool) -> void:
	if toggled_on:
		arrows_panel.disable_buttons(false)
		arrows_panel_2.disable_buttons(false)
		arrows_panel.set_long_slide_texture()
		arrows_panel_2.set_long_slide_texture()
	else:
		arrows_panel.disable_buttons(true)
		arrows_panel_2.disable_buttons(true)
		LONG_RELEASE_SELECTION.emit(false)
	
	long_double_arrow_pressed = toggled_on


func _on_arrows_panel_toggled(index: int) -> void:
	ARROW_DIRECTION_SELECTION.emit(index)


func _on_arrows_panel_2_toggled(index: int) -> void:
	ARROW_2_DIRECTION_SELECTION.emit(index)


func _on_arrows_panel_untoggled() -> void:
	ARROW_DIRECTION_SELECTION.emit(GlobalSettings.Directions.NONE)


func _on_arrows_panel_2_untoggled() -> void:
	ARROW_DIRECTION_SELECTION.emit(GlobalSettings.Directions.NONE)
