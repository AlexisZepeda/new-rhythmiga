class_name ArrowPanelButton
extends Button

@export var arrow_texture: TextureRect

@export_category("Textures")
@export var slide_texture: Texture2D
@export var long_slide_texture: Texture2D


func set_texture_pivot_offset() -> void:
	var texture_size: Vector2 = arrow_texture.size
	var texture_pivot_offset: Vector2 = texture_size / 2
	
	arrow_texture.pivot_offset = texture_pivot_offset


func dim_texture() -> void:
	arrow_texture.set_modulate(Color(1, 1, 1, 0.5))


func lighten_texture() -> void:
	arrow_texture.set_modulate(Color(1, 1, 1, 1))


func load_slide_texture() -> void:
	arrow_texture.set_texture(slide_texture)


func load_long_slide_texture() -> void:
	arrow_texture.set_texture(long_slide_texture)
