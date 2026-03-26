class_name LongNoteGridSprite
extends Sprite2D

@export_category("Children")
@export var back: Sprite2D
@export var line: Line2D

var is_set_back: bool = false
var front_cell: Vector2 = Vector2(-1, -1)
var back_cell: Vector2 = Vector2(-1, -1)


func _ready() -> void:
	if not line:
		await self.ready
	
	line.add_point(to_local(self.global_position), 0)
	line.add_point(to_local(back.global_position), 1)


func set_back(_position: Vector2) -> void:
	is_set_back = true
	
	back.global_position = _position


func hover_back_position(_position: Vector2, scroll_offset: int) -> void:
	if (_position.x - scroll_offset) <= self.global_position.x:
		return
	
	back.global_position.x = _position.x - scroll_offset
	
	line.set_point_position(1, to_local(back.global_position))


func set_line_points() -> void:
	line.set_point_position(0, to_local(self.global_position))
	line.set_point_position(1, to_local(back.global_position))
