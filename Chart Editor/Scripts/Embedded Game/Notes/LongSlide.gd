class_name LongSlideNote
extends Note

@export var line: Line2D: set = set_line

@export_category("Children")
@export var arrow: Sprite2D

var direction: Enums.Direction:
	set(value):
		direction = value
		_set_rotation()
		#print("Direction %s" % direction)


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


func _ready() -> void:
	var _arrow_sprite_height: float = arrow.texture.get_height()
	var _arrow_drawing_offset: float = _arrow_sprite_height / 2.0
		
	arrow.offset.y = -_arrow_drawing_offset


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


func evaluate(param_delta: float) -> bool:
	var hit_delta: float = param_delta
	if hit_delta < -HIT_MARGIN_MISS:
		# Note is not hittable, do nothing.
		print("	Released too soon %s" % hit_delta)
		hit_bad()
		return true
	elif -HIT_MARGIN_PERFECT <= hit_delta and hit_delta <= HIT_MARGIN_PERFECT:
		# Hit on time, perfect.
		print_rich("	[color=yellow]Perfect[/color]")
		hit_perfect()
		return true
	elif -HIT_MARGIN_CRITICAL <= hit_delta and hit_delta <= HIT_MARGIN_CRITICAL:
		print_rich("	[color=orange]Critical[/color]")
		hit_critical()
		return true
	elif -HIT_MARGIN_GREAT <= hit_delta and hit_delta <= HIT_MARGIN_GREAT:
		print_rich("	[color=green]Great[/color]")
		hit_great()
		return true
	elif -HIT_MARGIN_GOOD <= hit_delta and hit_delta <= HIT_MARGIN_GOOD:
		# Hit slightly off time, good.
		print_rich("	[color=blue]Good[/color]")
		hit_good()
		return true
		#if hit_delta < 0:
			#note_hit.emit(note.beat, Enums.HitType.GOOD_EARLY, hit_delta)
		#else:
			#note_hit.emit(note.beat, Enums.HitType.GOOD_LATE, hit_delta)
	elif -HIT_MARGIN_BAD <= hit_delta and hit_delta <= HIT_MARGIN_BAD:
		hit_bad()
		return true
	elif -HIT_MARGIN_MISS <= hit_delta and hit_delta <= HIT_MARGIN_MISS:
		# Hit way off time, miss.
		print("Note Miss")
		hit_bad()
		return true
		#if hit_delta < 0:
			#note_hit.emit(note.beat, Enums.HitType.MISS_EARLY, hit_delta)
		#else:
			#note_hit.emit(note.beat, Enums.HitType.MISS_LATE, hit_delta)
	
	print("Failed all conditionals")
	return false


func evaluate_release(param_delta: float) -> bool:
	var hit_delta: float = param_delta
	if hit_delta < -HIT_MARGIN_MISS:
		# Note is not hittable, do nothing.
		print("	Released too soon %s" % hit_delta)
		hit_bad()
		return true
	else:
		return false


func evaluate_slide(param_delta: float, param_direction:Enums.Direction=Enums.Direction.UP) -> bool:
	print("Note direction %s" % [Enums.Direction.keys()[direction]])
	print("Param direction %s" % [Enums.Direction.keys()[param_direction]])
	if param_direction != direction:
		print("Wrong direction")
		#hit_bad()
		return false
	else:
		return evaluate(param_delta)
