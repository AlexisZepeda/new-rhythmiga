class_name Cursor
extends Control

signal MOUSE_RIGHT_CLICK(cell: Vector2)
signal MOUSE_LEFT_CLICK(cell: Vector2)
signal MOUSE_LEFT_RELEASE(cell: Vector2)
signal MOUSE_HOVER(mouse_position: Vector2, cell: Vector2)

@export var grid: Grid
@export var scroll_container: ScrollContainer

@export_category("Hover Textures")
@export var tap_texture: Texture2D
@export var arrow_base_texture: Texture2D
@export var long_texture: Texture2D
@export var long_back_texture: Texture2D
@export_category("")

var _hover_texture: Sprite2D = Sprite2D.new()

var coordinates: Vector2 = Vector2(0, 0)
var current_cell: Vector2 = Vector2(0, 0)

var within_grid: bool = false

var hover_color: Color = Color.WHITE_SMOKE


func _ready() -> void:
	_hover_texture.modulate = Color(1.0, 1.0, 1.0, 0.5)
	add_child(_hover_texture)


func _physics_process(_delta: float) -> void:
	var mouse_position: Vector2 = get_local_mouse_position()
	
	var cell: Vector2 = grid.calculate_grid_coordinates(mouse_position)
	
	if grid.is_within_bounds(cell):
		within_grid = true
		hover(cell)
		#_hover_texture.position = mouse_position
		_hover_texture.global_position = coordinates
	
		_hover_texture.show()
	else:
		within_grid = false
		current_cell = Vector2(-1, -1)
		_hover_texture.hide()


func _input(event: InputEvent) -> void:
	if within_grid:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			MOUSE_LEFT_CLICK.emit(current_cell)
		
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			MOUSE_RIGHT_CLICK.emit(current_cell)
		
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			MOUSE_LEFT_RELEASE.emit(current_cell)
		
		if event is InputEventMouseMotion:
			MOUSE_HOVER.emit(get_local_mouse_position(), current_cell)
	else:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			MOUSE_LEFT_CLICK.emit(current_cell)
		
		if event is InputEventMouseMotion:
			MOUSE_HOVER.emit(get_local_mouse_position(), current_cell)


func _on_lines_image_length_changed(length: int) -> void:
	self.size.x = length


func resize(top_margin: float, _size: float) -> void:
	self.position.y = top_margin
	self.size.y  = _size


## Draws cell the mouse is currently hovering over.
func hover(cell: Vector2) -> void:
	if current_cell == cell:
		return
	
	current_cell = cell
	coordinates = grid.calculate_map_position_with_offset(cell)
	coordinates.x = coordinates.x - scroll_container.scroll_horizontal


func set_toggle_tap() -> void:
	_hover_texture.texture = tap_texture
	hover_color = Color.RED


func set_toggle_arrow() -> void:
	_hover_texture.texture = arrow_base_texture
	hover_color = Color.BLUE


func set_toggle_long() -> void:
	_hover_texture.texture = long_texture
	hover_color = Color.GREEN


func set_toggle_long_back() -> void:
	_hover_texture.texture = long_back_texture
	hover_color = Color.GREEN


func set_toggle_none() -> void:
	_hover_texture.texture = null
	hover_color = Color.WHITE_SMOKE


func pause() -> void:
	set_process(false)
	set_physics_process(false)


func unpause() -> void:
	set_process(true)
	set_physics_process(true)
