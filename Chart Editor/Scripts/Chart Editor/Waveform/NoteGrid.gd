class_name NoteGrid
extends Node2D

signal LONG_NOTE_SET
signal CLEARED

@export var grid: Grid
@export var current_notes: CurrentNotes
@export_category("Hover Textures")
@export var _tap_texture: Texture2D
@export_category("")

@export var scroll_container: ScrollContainer

@export var _long_note_grid_sprite_prefab: PackedScene
@export var _long_note_arrow_grid_sprite_prefab: PackedScene
@export var _long_note_double_arrow_grid_sprite_prefab: PackedScene
@export var _arrow_note_grid_sprite_prefab: PackedScene
@export var _double_arrow_note_grid_sprite_prefab: PackedScene


enum NoteType {
	TAP,
	ARROW,
	DOUBLE_ARROW,
	LONG,
	LONG_BACK,
	LONG_ARROW,
	LONG_DOUBLE_ARROW,
}

enum Keys {
	NOTE_TYPE,
	SPRITE,
	NOTE,
}

enum EnumLongNote {
	NONE,
	FRONT,
	BACK,
}

const MAX_ARROWS_IN_COLUMN: int = 2

var loading: bool = false
var _cells: Dictionary = {}
var _occupied_cells_by_lines: Array = []

var _long_note: EnumLongNote = EnumLongNote.NONE:
	set(value):
		_long_note = value
		
		match _long_note:
			EnumLongNote.FRONT:
				long_note_sprite = _long_note_grid_sprite_prefab.instantiate()
			EnumLongNote.BACK:
				if not loading:
					LONG_NOTE_SET.emit()

var long_note_sprite: LongNoteGridSprite = null:
	set(value):
		if not is_instance_valid(value):
			long_note_sprite = value
			_long_note = EnumLongNote.FRONT
		else:
			long_note_sprite = value
#var _held_sprite: NoteGridSprite = null
#var _current_cell: Vector2 = Vector2(-1, -1)


func _ready() -> void:
	grid.cell_position_change.connect(_on_cell_position_change)


func _on_cell_position_change() -> void:
	if not _cells.is_empty():
		for key in _cells:
			var sprite: Sprite2D = _cells[key][Keys.SPRITE]
			var cell: Vector2 = key
			
			#print("Note type %s" % NoteType.keys()[_cells[key][Keys.NOTE_TYPE]])
			match _cells[key][Keys.NOTE_TYPE]:
				NoteType.LONG:
					sprite.global_position = grid.calculate_map_position_with_offset(cell)
				NoteType.LONG_BACK, NoteType.LONG_ARROW, NoteType.LONG_DOUBLE_ARROW:
					pass
				_:
					sprite.global_position = grid.calculate_map_position_with_offset(cell)


func _set_cells(cell: Vector2, note_type: NoteType, sprite: Sprite2D, note: ChartNote) -> void:
	if _cells.has(cell):
		return
	
	_cells.set(cell, [note_type, sprite, note])
	current_notes.set_note(note.beat, note)


func _on_ui_editor_add_tap_note(cell: Vector2) -> void:
	#print("Cell %s" % cell)
	
	if is_occupied(cell) or _occupied_cells_by_lines.has(cell):
		print("Cell is occupied.")
		return
	
	if not grid.is_within_bounds(cell):
		print("Not inside grid bounds")
		return
	
	var beat: float = float(cell.x) / GlobalSettings.beat_duration
	var lane: int = int(cell.y)
	
	var sprite: NoteGridSprite = NoteGridSprite.new()
	var note: ChartNote = ChartNote.new(beat, ChartNote.Note_Type.TAP, lane)
	sprite.texture = _tap_texture
	sprite.snap = grid.cell_size / 2
	sprite.global_position = grid.calculate_map_position_with_offset(cell)
	
	_set_cells(cell, NoteType.TAP, sprite, note)
	add_child(sprite)


func _on_ui_editor_drop_tap_note(_cell: Vector2) -> void:
	pass


func _on_ui_editor_add_arrow_note(cell: Vector2, direction: GlobalSettings.Directions) -> void:
	if is_occupied(cell) or _occupied_cells_by_lines.has(cell):
		print("Cell is occupied.")
		return
	
	if not grid.is_within_bounds(cell):
		print("Not inside grid bounds")
		return
	
	if is_arrow_limit(cell, NoteType.ARROW):
		print("Cannot add more arrow notes.")
		return
	
	if direction == GlobalSettings.Directions.NONE:
		print("No direction selected.")
		return
	
	var beat: float = float(cell.x) / GlobalSettings.beat_duration
	var lane: int = int(cell.y)
	var sprite: ArrowNoteGridSprite = _arrow_note_grid_sprite_prefab.instantiate()
	var note: ChartNote = ChartNote.new(beat, ChartNote.Note_Type.ARROW, lane, direction)
	
	sprite.global_position = grid.calculate_map_position_with_offset(cell)
	sprite.set_arrow_direction(direction)
	
	_set_cells(cell, NoteType.ARROW, sprite, note)
	add_child(sprite)


func _on_ui_editor_add_double_arrow_note(cell: Vector2, direction_1: int, direction_2: int) -> void:
	if is_occupied(cell) or _occupied_cells_by_lines.has(cell):
		print("Cell is occupied.")
		return
	
	if not grid.is_within_bounds(cell):
		print("Not inside grid bounds")
		return
	
	if is_arrow_limit(cell, NoteType.DOUBLE_ARROW):
		print("Cannot add more arrow notes.")
		return
	
	if direction_1 == GlobalSettings.Directions.NONE or direction_2 == GlobalSettings.Directions.NONE:
		print("One or two directions not selected.")
		return
	
	var beat: float = float(cell.x) / GlobalSettings.beat_duration
	var lane: int = int(cell.y)
	var sprite: DoubleArrowNoteGridSprite = _double_arrow_note_grid_sprite_prefab.instantiate()
	var note: ChartNote = ChartNote.new(beat, ChartNote.Note_Type.DOUBLE_ARROW, lane, direction_1, direction_2)
	
	sprite.global_position = grid.calculate_map_position_with_offset(cell)
	sprite.set_arrow_direction(direction_1, direction_2)
	
	_set_cells(cell, NoteType.DOUBLE_ARROW, sprite, note)
	add_child(sprite)


func _on_ui_editor_add_long_note(cell: Vector2) -> void:
	if is_occupied(cell) or _occupied_cells_by_lines.has(cell):
		print("Cell is occupied.")
		return
		
	if not grid.is_within_bounds(cell):
		print("Not inside grid bounds")
		return
		
	if _long_note == EnumLongNote.NONE:
		_long_note = EnumLongNote.FRONT
	
	var beat: float = float(cell.x) / GlobalSettings.beat_duration
	var lane: int = int(cell.y)
	var note: ChartNote
	
	# Turn the hover toggle into a back long note
	
	# Change state when finished adding note
	match _long_note:
		EnumLongNote.FRONT:
			#print("Front")
			#print("Cell %s" % cell)
			note = ChartNote.new(beat, ChartNote.Note_Type.LONG, lane)
			long_note_sprite = _long_note_grid_sprite_prefab.instantiate()
			
			#sprite.texture = _long_texture
			
			long_note_sprite.global_position = grid.calculate_map_position_with_offset(cell)
			long_note_sprite.front_cell = cell
			_set_cells(cell, NoteType.LONG, long_note_sprite, note)
			add_child(long_note_sprite)
			_long_note = EnumLongNote.BACK
		EnumLongNote.BACK:
			#print("Back")
			#print("Input cell %s" % cell)
			#print("Cell %s" % grid.calculate_grid_coordinates_with_offset(long_note_sprite.back.global_position))
			note = ChartNote.new(beat, ChartNote.Note_Type.LONG_BACK, lane)
			
			var back_cell: Vector2 = grid.calculate_grid_coordinates_with_offset(long_note_sprite.back.global_position)
			long_note_sprite.back_cell = cell
			
			_find_occupied_cells(long_note_sprite.front_cell, long_note_sprite.back_cell)
			_set_cells(cell, NoteType.LONG_BACK, long_note_sprite, note)
			_long_note = EnumLongNote.NONE


func _on_ui_editor_add_long_arrow_note(cell: Vector2, direction: int) -> void:
	if is_occupied(cell) or _occupied_cells_by_lines.has(cell):
		print("Cell is occupied.")
		return
	
	if not grid.is_within_bounds(cell):
		print("Not inside grid bounds")
		return
	
	if _long_note == EnumLongNote.NONE:
		_long_note = EnumLongNote.FRONT
	
	var beat: float = float(cell.x) / GlobalSettings.beat_duration
	var lane: int = int(cell.y)
	var note: ChartNote
	
	# Turn the hover toggle into a back long note
	
	# Change state when finished adding note
	match _long_note:
		EnumLongNote.FRONT:
			note = ChartNote.new(beat, ChartNote.Note_Type.LONG, lane)
			long_note_sprite = _long_note_arrow_grid_sprite_prefab.instantiate()
			
			print("Created Long Arrow")
			
			long_note_sprite.global_position = grid.calculate_map_position_with_offset(cell)
			long_note_sprite.front_cell = cell
			_set_cells(cell, NoteType.LONG, long_note_sprite, note)
			add_child(long_note_sprite)
			_long_note = EnumLongNote.BACK
		EnumLongNote.BACK:
			var back_cell: Vector2 = grid.calculate_grid_coordinates_with_offset(long_note_sprite.back.global_position)
			long_note_sprite.back_cell = cell
			
			if is_arrow_limit(back_cell, NoteType.LONG_ARROW):
				print("Cannot add more arrow notes.")
				return
			
			if direction == GlobalSettings.Directions.NONE:
				print("Direction not selected.")
				return
			
			print("Cell %s" % grid.calculate_grid_coordinates_with_offset(long_note_sprite.back.global_position))
			note = ChartNote.new(beat, ChartNote.Note_Type.LONG_ARROW, lane, direction)
			long_note_sprite.set_arrow_direction(direction)
			_find_occupied_cells(long_note_sprite.front_cell, long_note_sprite.back_cell)
			_set_cells(cell, NoteType.LONG_ARROW, long_note_sprite, note)
			_long_note = EnumLongNote.NONE


func _on_ui_editor_add_long_double_arrow_note(cell: Vector2, direction: int, direction_2: int) -> void:
	if is_occupied(cell) or _occupied_cells_by_lines.has(cell):
		print("Cell is occupied.")
		return
	
	if not grid.is_within_bounds(cell):
		print("Not inside grid bounds")
		return
	
	if _long_note == EnumLongNote.NONE:
		_long_note = EnumLongNote.FRONT
	var beat: float = float(cell.x) / GlobalSettings.beat_duration
	var lane: int = int(cell.y)
	var note: ChartNote
	
	# Turn the hover toggle into a back long note
	
	# Change state when finished adding note
	match _long_note:
		EnumLongNote.FRONT:
			note = ChartNote.new(beat, ChartNote.Note_Type.LONG, lane)
			long_note_sprite = _long_note_double_arrow_grid_sprite_prefab.instantiate()
			
			#sprite.texture = _long_texture
			
			long_note_sprite.global_position = grid.calculate_map_position_with_offset(cell)
			long_note_sprite.front_cell = cell
			_set_cells(cell, NoteType.LONG_DOUBLE_ARROW, long_note_sprite, note)
			add_child(long_note_sprite)
			_long_note = EnumLongNote.BACK
		EnumLongNote.BACK:
			var back_cell: Vector2 = grid.calculate_grid_coordinates_with_offset(long_note_sprite.back.global_position)
			long_note_sprite.back_cell = cell
			
			if is_arrow_limit(back_cell, NoteType.LONG_DOUBLE_ARROW):
				print("Cannot add more arrow notes.")
				return
			
			if direction == GlobalSettings.Directions.NONE or direction_2 == GlobalSettings.Directions.NONE:
				print("One or two directions not selected.")
				return
			
			print("Cell %s" % grid.calculate_grid_coordinates_with_offset(long_note_sprite.back.global_position))
			note = ChartNote.new(beat, ChartNote.Note_Type.LONG_DOUBLE_ARROW, lane, direction, direction_2)
			long_note_sprite.set_arrow_direction(direction, direction_2)
			_find_occupied_cells(long_note_sprite.front_cell, long_note_sprite.back_cell)
			_set_cells(cell, NoteType.LONG_DOUBLE_ARROW, long_note_sprite, note)
			_long_note = EnumLongNote.NONE


func _on_ui_editor_remove_note(cell: Vector2) -> void:
	print(_cells)
	
	if not is_occupied(cell):
		print("Nothing to remove")
		return
	
	if _cells.has(cell):
		match _cells[cell][Keys.NOTE_TYPE]:
			NoteType.LONG, NoteType.LONG_BACK, NoteType.LONG_ARROW, NoteType.LONG_DOUBLE_ARROW:
				# Find the other cell connected to the note.
				var note_sprite_grid: LongNoteGridSprite = _cells[cell][Keys.SPRITE]
				if note_sprite_grid.front_cell == cell:
					current_notes.remove_note(_cells[note_sprite_grid.front_cell][Keys.NOTE].beat, _cells[note_sprite_grid.front_cell][Keys.NOTE])
					if note_sprite_grid.back_cell != Vector2(-1.0, -1.0):
						current_notes.remove_note(_cells[note_sprite_grid.back_cell][Keys.NOTE].beat, _cells[note_sprite_grid.back_cell][Keys.NOTE])
				else:
					current_notes.remove_note(_cells[note_sprite_grid.front_cell][Keys.NOTE].beat, _cells[note_sprite_grid.front_cell][Keys.NOTE])
					current_notes.remove_note(_cells[note_sprite_grid.back_cell][Keys.NOTE].beat, _cells[note_sprite_grid.back_cell][Keys.NOTE])
				
				_erase_occupied_cells(note_sprite_grid.front_cell, note_sprite_grid.back_cell)
				_cells[cell][Keys.SPRITE].queue_free()
				_cells.erase(note_sprite_grid.front_cell)
				_cells.erase(note_sprite_grid.back_cell)
				long_note_sprite = null
			NoteType.TAP:
				_cells[cell][Keys.SPRITE].queue_free()
				
				current_notes.remove_note(_cells[cell][Keys.NOTE].beat, _cells[cell][Keys.NOTE])
				_cells.erase(cell)
			NoteType.ARROW:
				_cells[cell][Keys.SPRITE].queue_free()
				
				current_notes.remove_note(_cells[cell][Keys.NOTE].beat, _cells[cell][Keys.NOTE])
				_cells.erase(cell)
			NoteType.DOUBLE_ARROW:
				_cells[cell][Keys.SPRITE].queue_free()
				
				current_notes.remove_note(_cells[cell][Keys.NOTE].beat, _cells[cell][Keys.NOTE])
				_cells.erase(cell)


func _on_ui_editor_hover_long_note(cell: Vector2) -> void:
	if _long_note == EnumLongNote.BACK:
		var _position: Vector2 = grid.calculate_map_position_with_offset(cell)
		
		if is_instance_valid(long_note_sprite):
			long_note_sprite.hover_back_position(_position, scroll_container.scroll_horizontal)


func _find_occupied_cells(beginning_cell: Vector2, end_cell: Vector2) -> void:
	var start = beginning_cell.x
	var end = end_cell.x
	
	for i in range(start + 1, end):
		_occupied_cells_by_lines.append(Vector2(i, beginning_cell.y))


func _erase_occupied_cells(beginning_cell: Vector2, end_cell: Vector2) -> void:
	var start = beginning_cell.x
	var end = end_cell.x
	
	for i in range(start + 1, end):
		_occupied_cells_by_lines.erase(Vector2(i, beginning_cell.y))


func _add_long_back_note(cell: Vector2, note_type: NoteType, 
	direction: GlobalSettings.Directions=GlobalSettings.Directions.NONE, 
	direction_2: GlobalSettings.Directions=GlobalSettings.Directions.NONE) -> void:
	
	if _long_note == EnumLongNote.BACK:
		var beat: float = float(cell.x) / GlobalSettings.beat_duration
		var lane: int = int(cell.y)
		var note: ChartNote
		match note_type:
			NoteType.LONG_BACK:
				#print("Cell %s" % grid.calculate_grid_coordinates_with_offset(long_note_sprite.back.global_position))
				note = ChartNote.new(beat, ChartNote.Note_Type.LONG_BACK, lane)
				
				print("Cell %s" % cell)
				
				var sprite_position: Vector2 = grid.calculate_map_position_with_offset(cell)
				
				print("Sprite position %s" % sprite_position)
				print("Scroll container %s" % scroll_container.scroll_horizontal)
				
				long_note_sprite.back_cell = cell
				long_note_sprite.back.global_position.x = sprite_position.x - scroll_container.scroll_horizontal
				long_note_sprite.set_line_points()
				
				_find_occupied_cells(long_note_sprite.front_cell, long_note_sprite.back_cell)
				_set_cells(cell, NoteType.LONG_BACK, long_note_sprite, note)
				_long_note = EnumLongNote.NONE
			NoteType.LONG_ARROW:
				long_note_sprite.back_cell = cell
				
				if is_arrow_limit(cell, NoteType.LONG_ARROW):
					print("Cannot add more arrow notes.")
					return
				
				note = ChartNote.new(beat, ChartNote.Note_Type.LONG_ARROW, lane, direction)
				var sprite_position: Vector2 = grid.calculate_map_position_with_offset(cell)
				long_note_sprite.back.global_position.x = sprite_position.x - scroll_container.scroll_horizontal
				long_note_sprite.set_line_points()
				
				long_note_sprite.set_arrow_direction(direction)
				_find_occupied_cells(long_note_sprite.front_cell, long_note_sprite.back_cell)
				_set_cells(cell, NoteType.LONG_ARROW, long_note_sprite, note)
				_long_note = EnumLongNote.NONE
			NoteType.LONG_DOUBLE_ARROW:
				long_note_sprite.back_cell = cell
				
				if is_arrow_limit(cell, NoteType.LONG_DOUBLE_ARROW):
					print("Cannot add more arrow notes.")
					return
				
				note = ChartNote.new(beat, ChartNote.Note_Type.LONG_DOUBLE_ARROW, lane, direction, direction_2)
				var sprite_position: Vector2 = grid.calculate_map_position_with_offset(cell)
				long_note_sprite.back.global_position.x = sprite_position.x - scroll_container.scroll_horizontal
				long_note_sprite.set_line_points()
				
				long_note_sprite.set_arrow_direction(direction, direction_2)
				_find_occupied_cells(long_note_sprite.front_cell, long_note_sprite.back_cell)
				_set_cells(cell, NoteType.LONG_DOUBLE_ARROW, long_note_sprite, note)
				_long_note = EnumLongNote.NONE


## Returns [code]true[/code] if [member _cells] contains [param cell].
func is_occupied(cell: Vector2) -> bool:
	return _cells.has(cell)


## Returns all [Note] objects found in [member _cells].
func get_all_notes() -> Array:
	var result: Array = []
	
	for cell in _cells:
		result.append(_cells[cell][Keys.NOTE])
	
	return result


## Returns [code]true[/code] if the column of [param cell.x] has more than [constant MAX_ARROWS_IN_COLUMN]
## occupied arrow [Note].
func is_arrow_limit(cell: Vector2, note_type: NoteType) -> bool:
	var count: int = 0
	
	match note_type:
		NoteType.ARROW, NoteType.LONG_ARROW:
			count += 1
		NoteType.DOUBLE_ARROW, NoteType.LONG_DOUBLE_ARROW:
			count += 2
	
	for key: Vector2 in _cells:
		if key.x != cell.x:
			continue
		
		match _cells[key][Keys.NOTE_TYPE]:
			NoteType.ARROW, NoteType.LONG_ARROW:
				count += 1
			NoteType.DOUBLE_ARROW, NoteType.LONG_DOUBLE_ARROW:
				count += 2
		
		if count > MAX_ARROWS_IN_COLUMN:
			return true
	
	return false


func load_notes(_notes: Dictionary) -> void:
	if _notes.is_empty():
		print("No notes to load.")
		return
	
	loading = true
	
	for cell: Vector2 in _notes:
		var _note: Array = _notes[cell]
		
		var _note_type: NoteType = _notes[cell][0]
		
		#print("Note Type %s" % _note_type)
		
		match _note_type:
			NoteType.TAP:
				_on_ui_editor_add_tap_note(cell)
			NoteType.ARROW:
				var _direction: GlobalSettings.Directions = _notes[cell][1] as GlobalSettings.Directions
				
				_on_ui_editor_add_arrow_note(cell, _direction)
			NoteType.DOUBLE_ARROW:
				var _direction: GlobalSettings.Directions = _notes[cell][1] as GlobalSettings.Directions
				var _direction_2: GlobalSettings.Directions = _notes[cell][2] as GlobalSettings.Directions
				
				_on_ui_editor_add_double_arrow_note(cell, _direction, _direction_2)
			NoteType.LONG:
				_on_ui_editor_add_long_note(cell)
			NoteType.LONG_BACK:
				_add_long_back_note(cell, _note_type)
			NoteType.LONG_ARROW:
				var _direction: GlobalSettings.Directions = _notes[cell][1] as GlobalSettings.Directions
				
				var new_long_note_sprite: LongNoteArrowGridSprite = _long_note_arrow_grid_sprite_prefab.instantiate()
				
				_cells[long_note_sprite.front_cell][Keys.SPRITE] = new_long_note_sprite
				
				new_long_note_sprite.global_position = long_note_sprite.global_position
				new_long_note_sprite.front_cell = long_note_sprite.front_cell
				
				long_note_sprite.queue_free()
				
				long_note_sprite = new_long_note_sprite
				add_child(long_note_sprite)
				
				_add_long_back_note(cell, _note_type, _direction)
			NoteType.LONG_DOUBLE_ARROW:
				var _direction: GlobalSettings.Directions = _notes[cell][1] as GlobalSettings.Directions
				var _direction_2: GlobalSettings.Directions = _notes[cell][2] as GlobalSettings.Directions
				
				var new_long_note_sprite: LongNoteDoubleArrowGridSprite = _long_note_double_arrow_grid_sprite_prefab.instantiate()
				_cells[long_note_sprite.front_cell][Keys.SPRITE] = new_long_note_sprite
				
				new_long_note_sprite.global_position = long_note_sprite.global_position
				new_long_note_sprite.front_cell = long_note_sprite.front_cell
				
				long_note_sprite.queue_free()
				
				long_note_sprite = new_long_note_sprite
				add_child(long_note_sprite)
				
				_add_long_back_note(cell, _note_type, _direction, _direction_2)
	
	loading = false


## Remove all objects from NoteGrid.
func clear_grid() -> void:
	if not _cells.is_empty():
		
		print("Initial _cells")
		print(_cells)
		
		for cell in _cells:
			print(cell)
			current_notes.remove_note(cell.x, _cells[cell][Keys.NOTE])
			_cells[cell][Keys.NOTE] = null
			_cells[cell][Keys.SPRITE].queue_free()
		
		_cells.clear()
		
		print("Cleared _cells")
		print(_cells)
	
	CLEARED.emit()
