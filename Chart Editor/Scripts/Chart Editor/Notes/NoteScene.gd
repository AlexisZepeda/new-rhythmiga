class_name NoteGridSprite
extends Sprite2D

var _offset: Vector2 = Vector2.ZERO
var dragging: bool = false

var snap: Vector2 = Vector2.ZERO


func _process(_delta: float) -> void:
	if dragging:
		var new_position: Vector2 = get_global_mouse_position() - _offset
		
		position = Vector2(snapped(new_position.x, snap.x), snapped(new_position.y, snap.y))


func on_button_button_up() -> void:
	print("Pressed")
	
	dragging = false
	
	_offset = get_global_mouse_position() - global_position


func on_button_button_down() -> void:
	print("")
	
	dragging = true
