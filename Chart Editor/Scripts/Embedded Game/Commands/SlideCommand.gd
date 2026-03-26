class_name SlideCommand
extends Command

var direction: Enums.Direction


func _init(time: float, param_direction: Enums.Direction) -> void:
	super._init(time)
	direction = param_direction


func execute(object: NoteManager) -> bool:
	return object.handle_slide(direction)
