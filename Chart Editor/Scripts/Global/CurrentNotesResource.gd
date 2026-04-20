class_name CurrentNotes
extends Resource

var current_notes: Dictionary[float, Array] = {}


func set_note(key: float, value: ChartNote) -> void:
	if not current_notes.has(key):
		current_notes[key] = []
	
	current_notes[key].append(value)
	changed.emit()


func remove_note(key: float, value: ChartNote) -> bool:
	if not current_notes.has(key):
		return false
	
	if not current_notes[key].has(value):
		return false
	
	current_notes[key].erase(value)
	
	changed.emit()
	return true


func clear() -> void:
	current_notes.clear()
	
	changed.emit()
