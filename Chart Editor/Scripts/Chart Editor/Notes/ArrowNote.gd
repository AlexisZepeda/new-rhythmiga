class_name ArrowNoteGridSprite
extends Sprite2D

@export_category("Children")
@export var arrow: Sprite2D


func set_arrow_direction(direction: GlobalSettings.Directions) -> void:
	arrow.rotation_degrees = GlobalSettings.get_arrow_angle(direction)
