class_name ControlSlideNoteGridSprite
extends ControlNoteGridSprite


func _get_drag_data(_at_position: Vector2) -> Variant:
	print("Get drag data at %s" % position)
	var preview: TextureRect = TextureRect.new()
	preview.texture = texture
	set_drag_preview(preview)
	
	var note_drag_data: NoteDrag = NoteDrag.new(get_parent(), mouse_position, preview, NewNoteGrid.NoteType.ARROW)
	
	return note_drag_data
