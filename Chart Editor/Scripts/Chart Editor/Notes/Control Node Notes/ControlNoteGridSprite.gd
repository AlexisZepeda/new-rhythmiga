class_name ControlNoteGridSprite
extends TextureRect

var mouse_position: Vector2 = Vector2.ZERO



func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS


func _get_drag_data(_at_position: Vector2) -> Variant:
	print("Get drag data at %s" % position)
	var preview: TextureRect = TextureRect.new()
	preview.texture = texture
	set_drag_preview(preview)
	
	var note_drag_data: NoteDrag = NoteDrag.new(get_parent(), mouse_position, preview, NewNoteGrid.NoteType.TAP)
	
	return note_drag_data
