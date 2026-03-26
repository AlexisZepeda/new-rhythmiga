class_name TapReleaseCommand
extends Command


func execute(object: NoteManager) -> bool:
	return object.handle_release(key)
