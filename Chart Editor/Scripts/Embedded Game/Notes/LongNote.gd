class_name LongNote
extends Note

@export var line: Line2D: set = set_line
@export var back_note: Note

var release_back: bool = false


func _update_position() -> void:
	super._update_position()
	
	#print("Position %s line position %s" % [self.position, line.get_point_position(0)])
	line.set_point_position(0, self.position)


func set_line(value: Line2D) -> void:
	line = value
	
	line.add_point(self.position, 0)


func hit_bad(stop_movement: bool = true) -> void:
	release_back = true
	
	line.hit_bad()
	super.hit_bad(stop_movement)


func miss(stop_movement: bool = true) -> void:
	release_back = true
	
	line.miss()
	super.miss(stop_movement)


func evaluate_long(param_delta: float, key: Key, current_key: Key) -> bool:
	if key != current_key:
		print("Not correct key %s %s" % [OS.get_keycode_string(key), OS.get_keycode_string(current_key)])
		hit_bad()
		return false
	
	return evaluate(param_delta)
