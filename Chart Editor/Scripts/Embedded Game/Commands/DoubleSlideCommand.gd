class_name DoubleSlideCommand
extends Command

var direction_axis_right: Enums.Direction
var direction_axis_left: Enums.Direction


func _init(time: float, param_direction_right: Enums.Direction, param_direction_left: Enums.Direction) -> void:
	super._init(time)
	direction_axis_right = param_direction_right
	direction_axis_left = param_direction_left


func execute(object: NoteManager) -> bool:
	return object.handle_double_slide(direction_axis_right, direction_axis_left)
