class_name NoteDrag

signal drag_completed(data: NoteDrag)

var source: Control = null
var destination: Control = null

var note_type: NewNoteGrid.NoteType = NewNoteGrid.NoteType.TAP

var mouse_position: Vector2 = Vector2.ZERO

var preview: TextureRect = null


func _init(_source: Control, _mouse_position: Vector2, _preview: Control, _note_type: NewNoteGrid.NoteType) -> void:
	source = _source
	preview = _preview
	note_type = _note_type
	mouse_position = _mouse_position
	
	self.preview.tree_exiting.connect(_on_tree_exiting)


func _on_tree_exiting() -> void:
	drag_completed.emit(self)
