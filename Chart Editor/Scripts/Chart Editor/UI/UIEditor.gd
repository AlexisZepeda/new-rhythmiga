class_name AudioSpectrumUIEditor
extends Control

signal ADD_TAP_NOTE(cell: Vector2)
signal DROP_TAP_NOTE(cell: Vector2)

signal ADD_ARROW_NOTE(cell: Vector2, direction: GlobalSettings.Directions)

signal ADD_DOUBLE_ARROW_NOTE(cell: Vector2, direction: GlobalSettings.Directions, direction_2: GlobalSettings.Directions)

signal ADD_LONG_NOTE(cell: Vector2)
signal HOVER_LONG_NOTE(cell: Vector2)

signal ADD_LONG_ARROW_NOTE(cell: Vector2, direction: GlobalSettings.Directions)
signal ADD_LONG_DOUBLE_ARROW_NOTE(cell: Vector2, direction: GlobalSettings.Directions, direction_2: GlobalSettings.Directions)

signal REMOVE_NOTE(cell: Vector2)

@export var cursor: Cursor
@export var lines: Lines
@export var notes: NoteGrid
@export var audio_spectrum_analyzer: AudioSpectrumAnalyzer

enum Toggle {
	NONE,
	TAP,
	ARROW,
	DOUBLE_ARROW,
	LONG,
	LONG_BACK,
	LONG_ARROW,
	LONG_DOUBLE_ARROW,
}

var _note_toggle_state: Toggle = Toggle.NONE
var arrow_direction: GlobalSettings.Directions = GlobalSettings.Directions.NONE
var arrow_2_direction: GlobalSettings.Directions = GlobalSettings.Directions.NONE


func _on_tap_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_note_toggle_state = Toggle.TAP
		cursor.set_toggle_tap()
	else:
		_note_toggle_state = Toggle.NONE
		cursor.set_toggle_none()


func _on_arrow_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_note_toggle_state = Toggle.ARROW
		cursor.set_toggle_arrow()
	else:
		_note_toggle_state = Toggle.NONE
		cursor.set_toggle_none()


func _on_double_arrow_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_note_toggle_state = Toggle.DOUBLE_ARROW
		cursor.set_toggle_arrow()
	else:
		_note_toggle_state = Toggle.NONE
		cursor.set_toggle_none()


func _on_long_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_note_toggle_state = Toggle.LONG
		cursor.set_toggle_long()
	else:
		_note_toggle_state = Toggle.NONE
		cursor.set_toggle_none()


func _on_note_check_boxes_long_release_selection(toggled_on: bool) -> void:
	if toggled_on:
		_note_toggle_state = Toggle.LONG
		cursor.set_toggle_long()
	else:
		_note_toggle_state = Toggle.NONE
		cursor.set_toggle_none()


func _on_long_arrow_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_note_toggle_state = Toggle.LONG_ARROW
		cursor.set_toggle_long()
	else:
		_note_toggle_state = Toggle.NONE
		cursor.set_toggle_none()


func _on_long_double_arrow_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_note_toggle_state = Toggle.LONG_DOUBLE_ARROW
		cursor.set_toggle_long()
	else:
		_note_toggle_state = Toggle.NONE
		cursor.set_toggle_none()


func _on_note_grid_long_note_set() -> void:
	cursor.set_toggle_long_back()


func _on_cursor_mouse_left_click(cell: Vector2) -> void:
	match _note_toggle_state:
		Toggle.TAP:
			ADD_TAP_NOTE.emit(cell)
		Toggle.ARROW:
			ADD_ARROW_NOTE.emit(cell, arrow_direction)
		Toggle.DOUBLE_ARROW:
			ADD_DOUBLE_ARROW_NOTE.emit(cell, arrow_direction, arrow_2_direction)
		Toggle.LONG:
			ADD_LONG_NOTE.emit(cell)
		Toggle.LONG_ARROW:
			ADD_LONG_ARROW_NOTE.emit(cell, arrow_direction)
		Toggle.LONG_DOUBLE_ARROW:
			ADD_LONG_DOUBLE_ARROW_NOTE.emit(cell, arrow_direction, arrow_2_direction)
		Toggle.NONE:
			audio_spectrum_analyzer.seek_seconds()


func _on_cursor_mouse_left_release(cell: Vector2) -> void:
	match _note_toggle_state:
		Toggle.TAP:
			DROP_TAP_NOTE.emit(cell)


func _on_cursor_mouse_right_click(cell: Vector2) -> void:
	REMOVE_NOTE.emit(cell)


func _on_cursor_mouse_hover(mouse_position: Vector2, cell: Vector2) -> void:
	match _note_toggle_state:
		Toggle.NONE:
			audio_spectrum_analyzer.hover_time_graph_line(mouse_position)
		Toggle.LONG, Toggle.LONG_ARROW, Toggle.LONG_DOUBLE_ARROW:
			audio_spectrum_analyzer.clear_hover_time_graph_line()
			HOVER_LONG_NOTE.emit(cell)
		_:
			audio_spectrum_analyzer.clear_hover_time_graph_line()


func _on_note_check_boxes_arrow_direction_selection(direction: int) -> void:
	print(GlobalSettings.Directions.keys()[direction])
	arrow_direction = direction as GlobalSettings.Directions


func _on_note_check_boxes_arrow_2_direction_selection(direction: int) -> void:
	print(GlobalSettings.Directions.keys()[direction])
	arrow_2_direction = direction as GlobalSettings.Directions
