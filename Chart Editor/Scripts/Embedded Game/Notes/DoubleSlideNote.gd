class_name DoubleSlideNote
extends Note

@export_category("Children")
@export var arrow_1: Sprite2D
@export var arrow_2: Sprite2D

var _arrow_drawing_offset: float = 0.0:
	set(value):
		_arrow_drawing_offset = value
		_set_sprite_offset()

var direction_1: Enums.Direction:
	set(value):
		direction_1 = value
		_set_rotation(direction_1, arrow_1)
		#print("Direction %s" % direction)

var direction_2: Enums.Direction:
	set(value):
		direction_2 = value
		_set_rotation(direction_2, arrow_2)
		_set_sprite_offset()
		#print("Direction %s" % direction)


func _ready() -> void:
	var _arrow_sprite_height: float = arrow_1.texture.get_height()
	_arrow_drawing_offset = -_arrow_sprite_height / 2.0


func _set_sprite_offset() -> void:
	if direction_1 == direction_2:
		arrow_2.offset.y =_arrow_drawing_offset


func _set_rotation(direction: Enums.Direction, arrow: Sprite2D) -> void:
	match direction:
		Enums.Direction.UP:
			arrow.rotation_degrees = 0
		Enums.Direction.RIGHT:
			arrow.rotation_degrees = 90
		Enums.Direction.DOWN:
			arrow.rotation_degrees = 180
		Enums.Direction.LEFT:
			arrow.rotation_degrees = -90


func evaluate_slide(param_delta: float, param_direction: Enums.Direction=Enums.Direction.UP, param_direction_2: Enums.Direction=Enums.Direction.UP) -> bool:
	print("Note direction %s" % direction_1)
	print("Param direction %s" % param_direction)
	
	print("Note direction-2 %s" % direction_2)
	print("Param direction-2 %s" % param_direction_2)
	
	if direction_1 != param_direction and direction_1 != param_direction_2:
		print("false")
		return false
	elif direction_2 != param_direction and direction_2 != param_direction_2:
		print("false 2")
		return false
	else:
		return super.evaluate(param_delta)
