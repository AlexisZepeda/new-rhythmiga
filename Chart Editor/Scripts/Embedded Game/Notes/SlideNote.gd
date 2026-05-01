class_name SlideNote
extends Note

@export_category("Children")
@export var arrow: Sprite2D

var direction: Enums.Direction:
	set(value):
		direction = value
		_set_rotation()
		#print("Direction %s" % direction)


func _init() -> void:
	_speed = EmbeddedGlobalSettings.scroll_speed


func _ready() -> void:
	EmbeddedGlobalSettings.scroll_speed_changed.connect(_on_scroll_speed_changed)
	var _arrow_sprite_height: float = arrow.texture.get_height()
	var _arrow_drawing_offset: float = _arrow_sprite_height / 2.0
		
	arrow.offset.y = -_arrow_drawing_offset


func _set_rotation() -> void:
	#match direction:
		#Enums.Direction.UP:
			#arrow.rotation_degrees = 0
		#Enums.Direction.RIGHT:
			#arrow.rotation_degrees = 90
		#Enums.Direction.DOWN:
			#arrow.rotation_degrees = 180
		#Enums.Direction.LEFT:
			#arrow.rotation_degrees = -90
	var temp: GlobalSettings.Directions = int(direction) as GlobalSettings.Directions
	arrow.rotation_degrees = GlobalSettings.get_arrow_angle(temp)


#func evaluate(param_delta: float, param_direction:Enums.Direction=Enums.Direction.UP, _param_direction_2:Enums.Direction=Enums.Direction.UP, _key:Key=KEY_NONE) -> bool:
	#print("Note direction %s" % direction)
	#print("Param direction %s" % param_direction)
	#if param_direction != direction:
		#print("Wrong direction")
		##hit_bad()
		#return false
	#else:
		#return super.evaluate(param_delta)


func evaluate_slide(param_delta: float, param_direction:Enums.Direction=Enums.Direction.UP) -> bool:
	print("Note direction %s" % Enums.Direction.keys()[direction])
	print("Param direction %s" % Enums.Direction.keys()[param_direction])
	if param_direction != direction:
		print("Wrong direction")
		#hit_bad()
		return false
	else:
		return super.evaluate(param_delta)
