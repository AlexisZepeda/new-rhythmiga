class_name LongNoteDoubleArrowGridSprite
extends LongNoteGridSprite

@export_category("Children")
@export var arrow_1: Sprite2D
@export var arrow_2: Sprite2D

const OFFSET: float = 8.0

var direction_1: GlobalSettings.Directions = GlobalSettings.Directions.UP:
	set(value):
		direction_1 = value
		#print("Direction %s" % direction)

var direction_2: GlobalSettings.Directions = GlobalSettings.Directions.UP:
	set(value):
		direction_2 = value
		_set_sprite_offset()
		#print("Direction %s" % direction)


func _set_sprite_offset() -> void:
	if direction_1 == direction_2:
		arrow_2.offset.y = OFFSET


func set_arrow_direction(param_direction_1: GlobalSettings.Directions, param_direction_2: GlobalSettings.Directions) -> void:
	arrow_1.rotation_degrees = GlobalSettings.get_arrow_angle(param_direction_1)
	arrow_2.rotation_degrees = GlobalSettings.get_arrow_angle(param_direction_2)
	
	direction_1 = param_direction_1
	direction_2 = param_direction_2
	
	if direction_2 < direction_1:
		arrow_1.flip_v = true
		arrow_2.flip_v = true
	
	arrow_1.show()
	arrow_2.show()
	
