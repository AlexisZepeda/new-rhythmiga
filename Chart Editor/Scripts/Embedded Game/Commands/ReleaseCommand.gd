class_name ReleaseCommand
extends Command


func execute(object: NoteManager) -> bool:
	return object.handle_empty_release(key)
