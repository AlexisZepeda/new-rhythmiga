class_name AutoInputManager

static var BUTTONS_LIST: Dictionary = {
	KEY_E: false,
	KEY_F: false,
	KEY_I: false,
	KEY_J: false,
}


## Returns first [enum Key] from [member BUTTONS_LIST] which is [operator false].
static func get_unpressed_button() -> Key:
	for key: Key in BUTTONS_LIST:
		if not BUTTONS_LIST[key]:
			return key
	
	return KEY_NONE


static func set_buttons_list(key: Key, pressed: bool) -> void:
	BUTTONS_LIST[key] = pressed


static func button_is_pressed(key: Key) -> bool:
	return BUTTONS_LIST[key]
