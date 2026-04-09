class_name LongDoubleSlide
extends Note

@export var line: Line2D: set = set_line

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
		arrow_2.offset.y = _arrow_drawing_offset


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


func _update_position() -> void:
	super._update_position()
	
	if is_instance_valid(line):
		line.set_point_position(1, self.position)


func hit_perfect() -> void:
	if is_instance_valid(line):
		line.hit_perfect()
	super.hit_perfect()


func hit_critical() -> void:
	if is_instance_valid(line):
		line.hit_critical()
	super.hit_critical()


func hit_great() -> void:
	if is_instance_valid(line):
		line.hit_great()
	super.hit_great()


func hit_good() -> void:
	if is_instance_valid(line):
		line.hit_good()
	super.hit_good()


func hit_bad(stop_movement: bool = true) -> void:
	if is_instance_valid(line):
		line.hit_bad()
	super.hit_bad(stop_movement)


func miss(stop_movement: bool = true) -> void:
	if is_instance_valid(line):
		line.miss()
	super.miss(stop_movement)


func set_line(value: Line2D) -> void:
	line = value
	
	line.add_point(self.position, 1)


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
