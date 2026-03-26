class_name TapCommand
extends Command


func execute(object: NoteManager) -> bool:
	return object.handle_press(key)
