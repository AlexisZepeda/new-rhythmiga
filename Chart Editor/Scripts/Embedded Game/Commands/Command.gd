class_name Command

var pressed: float = 0.0: set = set_pressed
var key: Key = KEY_NONE: set = set_key
var process_attempts: int = 0


func _init(time: float = 0.0) -> void:
	pressed = time


func set_pressed(value: float) -> void:
	if value < 0.0:
		pressed = 0.0
	else:
		pressed = value


func set_key(value: Key) -> void:
	key = value


func increase_process_attempt() -> void:
	process_attempts += 1


func execute(_object: NoteManager) -> bool:
	return false


func is_stale(time: float) -> bool:
	return abs(pressed - time) > Note.HIT_MARGIN_BAD
