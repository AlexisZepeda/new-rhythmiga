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

enum OccupiedPositions {
	START=0,
	END=1,
}

const MAX_ARROWS_IN_COLUMN: int = 2

var loading: bool = false
var _cells: Dictionary = {}
var _occupied_cells_by_lines: Array = []
var _occupied_cells_by_position: Array = []

var _long_note: EnumLongNote = EnumLongNote.NONE:
	set(value):
		_long_note = value
		
		match _long_note:
			EnumLongNote.FRONT:
				long_note_sprite = _long_note_grid_sprite_prefab.instantiate()
			EnumLongNote.BACK:
				if not loading:
					LONG_NOTE_SET.emit()
			EnumLongNote.NONE:
				long_note_sprite = null

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


func _on_ui_editor_add_tap_note(cell: Vector2, _note_position: Vector2=Vector2.ZERO, _ticks: int=0) -> void:
	var sprite_position: Vector2 = grid.calculate_map_position_with_offset(cell)
	
	if not _can_place_note(cell, sprite_position, NoteType.TAP):
		print("Can't place note in this position")
		return
	
	var beat: float = float(cell.x) / GlobalSettings.beat_duration
	var lane: int = int(cell.y)
	
	var sprite: NoteGridSprite = NoteGridSprite.new()
	var note: ChartNote = ChartNote.new(beat, ChartNote.Note_Type.TAP, lane)
	sprite.texture = _tap_texture
	
	if _note_position != Vector2.ZERO:
		sprite.global_position = _note_position
	else:
		sprite.global_position = sprite_position
	
	if _ticks != 0:
		note.set_ticks(_ticks)
	
	note.set_position(sprite.global_position)
	
	_set_cells(cell, NoteType.TAP, sprite, note)
	add_child(sprite)


func _on_ui_editor_drop_tap_note(_cell: Vector2) -> void:
	pass


func _on_ui_editor_add_arrow_note(cell: Vector2, direction: GlobalSettings.Directions,
		_note_position: Vector2=Vector2.ZERO,
		_ticks: int=0) -> void:
	
	var sprite_position: Vector2 = grid.calculate_map_position_with_offset(cell)
	
	if not _can_place_note(cell, sprite_position, NoteType.ARROW):
		print("Can't place note in this position")
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
	
	if _note_position != Vector2.ZERO:
		sprite.global_position = _note_position
	else:
		sprite.global_position = sprite_position
	
	if _ticks != 0:
		note.set_ticks(_ticks)
	
	note.set_position(sprite.global_position)
	
	_set_cells(cell, NoteType.ARROW, sprite, note)
	add_child(sprite)


func _on_ui_editor_add_double_arrow_note(cell: Vector2, direction_1: int, direction_2: int,
		_note_position: Vector2=Vector2.ZERO,
		_ticks: int=0) -> void:
	var sprite_position: Vector2 = grid.calculate_map_position_with_offset(cell)
	
	if not _can_place_note(cell, sprite_position, NoteType.DOUBLE_ARROW):
		print("Can't place note in this position")
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
	
	if _note_position != Vector2.ZERO:
		sprite.global_position = _note_position
	else:
		sprite.global_position = sprite_position
	
	if _ticks != 0:
		note.set_ticks(_ticks)
	
	note.set_position(sprite.global_position)
	
	_set_cells(cell, NoteType.DOUBLE_ARROW, sprite, note)
	add_child(sprite)


func _on_ui_editor_add_long_note(cell: Vector2, _note_position: Vector2=Vector2.ZERO,
		_ticks: int=0) -> void:
	var sprite_position: Vector2 = grid.calculate_map_position_with_offset(cell)
	
	var temp_position: Vector2 = Vector2(sprite_position.x + scroll_container.scroll_horizontal, sprite_position.y)
	
	if not _can_place_note(cell, temp_position, NoteType.LONG):
		print("Can't place note in this position")
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
			
			print("Position %s" % sprite_position) 
			
			#long_note_sprite.global_position = grid.calculate_map_position_with_offset(cell)
			long_note_sprite.front_cell = cell
			if _ticks != 0:
				note.set_ticks(_ticks)
			
			if _note_position != Vector2.ZERO:
				long_note_sprite.global_position = _note_position
			else:
				long_note_sprite.global_position = sprite_position
			
			
			print("set position %s" % long_note_sprite.global_position)
			note.set_position(long_note_sprite.global_position)
			
			_set_cells(cell, NoteType.LONG, long_note_sprite, note)
			add_child(long_note_sprite)
			_long_note = EnumLongNote.BACK
		EnumLongNote.BACK:
			#print("Back")
			#print("Input cell %s" % cell)
			#print("Cell %s" % grid.calculate_grid_coordinates_with_offset(long_note_sprite.back.global_position))
			print("Front global position %s" % long_note_sprite.global_position)
			
			var scroll_start: Vector2 = Vector2(long_note_sprite.global_position.x + scroll_container.scroll_horizontal, long_note_sprite.global_position.y)
			var scroll_end: Vector2 = Vector2(long_note_sprite.back.global_position.x + scroll_container.scroll_horizontal, long_note_sprite.back.global_position.y)
			
			if not _can_place_note(cell, scroll_end, NoteType.LONG):
				print("Can't place note in this position")
				return
			
			if is_lines_occupied(scroll_start, scroll_end):
				print("Nested long note inside")
				return
			
			note = ChartNote.new(beat, ChartNote.Note_Type.LONG_BACK, lane)
			
			long_note_sprite.back_cell = cell
			
			if _ticks != 0:
				note.set_ticks(_ticks)
			
			if _note_position != Vector2.ZERO:
				long_note_sprite.back.global_position = _note_position
			#else:
				#long_note_sprite.back.global_position = grid.calculate_map_position_with_offset(cell)
			
			note.set_position(long_note_sprite.back.global_position)
			
			#_find_occupied_cells(long_note_sprite.front_cell, long_note_sprite.back_cell)
			_find_occupied_lines(long_note_sprite.global_position, long_note_sprite.back.global_position)
			_set_cells(cell, NoteType.LONG_BACK, long_note_sprite, note)
			_long_note = EnumLongNote.NONE


func _on_ui_editor_add_long_arrow_note(cell: Vector2, direction: int,
		_note_position: Vector2=Vector2.ZERO,
		_ticks: int=0) -> void:
	var sprite_position: Vector2 = grid.calculate_map_position_with_offset(cell)
	var temp_position: Vector2 = Vector2(sprite_position.x + scroll_container.scroll_horizontal, sprite_position.y)
	
	if not _can_place_note(cell, temp_position, NoteType.LONG):
		print("Can't place note in this position")
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
			
			#long_note_sprite.global_position = sprite_position
			long_note_sprite.front_cell = cell
			
			if _ticks != 0:
				note.set_ticks(_ticks)
			
			if _note_position != Vector2.ZERO:
				long_note_sprite.global_position = _note_position
			else:
				long_note_sprite.global_position = sprite_position
			
			note.set_position(long_note_sprite.global_position)
			
			_set_cells(cell, NoteType.LONG, long_note_sprite, note)
			add_child(long_note_sprite)
			_long_note = EnumLongNote.BACK
		EnumLongNote.BACK:
			var back_cell: Vector2 = grid.calculate_grid_coordinates_with_offset(long_note_sprite.back.global_position)
			
			var scroll_start: Vector2 = Vector2(long_note_sprite.global_position.x + scroll_container.scroll_horizontal, long_note_sprite.global_position.y)
			var scroll_end: Vector2 = Vector2(long_note_sprite.back.global_position.x + scroll_container.scroll_horizontal, long_note_sprite.back.global_position.y)
			
			if not _can_place_note(cell, scroll_end, NoteType.LONG):
				print("Can't place note in this position")
				return
			
			if is_lines_occupied(scroll_start, scroll_end):
				print("Nested long note inside")
				return
			
			if is_arrow_limit(back_cell, NoteType.LONG_ARROW):
				print("Cannot add more arrow notes.")
				return
			
			if direction == GlobalSettings.Directions.NONE:
				print("Direction not selected.")
				return
			
			long_note_sprite.back_cell = cell
			#print("Cell %s" % grid.calculate_grid_coordinates_with_offset(long_note_sprite.back.global_position))
			note = ChartNote.new(beat, ChartNote.Note_Type.LONG_ARROW, lane, direction)
			long_note_sprite.set_arrow_direction(direction)
			#_find_occupied_cells(long_note_sprite.front_cell, long_note_sprite.back_cell)
			_find_occupied_lines(long_note_sprite.global_position, long_note_sprite.back.global_position)
			_set_cells(cell, NoteType.LONG_ARROW, long_note_sprite, note)
			
			if _ticks != 0:
				note.set_ticks(_ticks)
				
			if _note_position != Vector2.ZERO:
				long_note_sprite.back.global_position = _note_position
			
			note.set_position(long_note_sprite.back.global_position)
			
			_long_note = EnumLongNote.NONE


func _on_ui_editor_add_long_double_arrow_note(cell: Vector2, direction: int, direction_2: int,
		_note_position: Vector2=Vector2.ZERO,
		_ticks: int=0) -> void:
	
	var sprite_position: Vector2 = grid.calculate_map_position_with_offset(cell)
	var temp_position: Vector2 = Vector2(sprite_position.x + scroll_container.scroll_horizontal, sprite_position.y)
	
	if not _can_place_note(cell, temp_position, NoteType.LONG):
		print("Can't place note in this position")
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
			
			long_note_sprite.global_position = sprite_position
			long_note_sprite.front_cell = cell
			
			print("Front cell %s" % cell)
			
			if _note_position != Vector2.ZERO:
				long_note_sprite.global_position = _note_position
			else:
				long_note_sprite.global_position = sprite_position
			
			_set_cells(cell, NoteType.LONG, long_note_sprite, note)
			add_child(long_note_sprite)
			
			if _ticks != 0:
				note.set_ticks(_ticks)
			
			note.set_position(long_note_sprite.global_position)
			
			_long_note = EnumLongNote.BACK
		EnumLongNote.BACK:
			var back_cell: Vector2 = grid.calculate_grid_coordinates_with_offset(long_note_sprite.back.global_position)
			
			var scroll_start: Vector2 = Vector2(long_note_sprite.global_position.x + scroll_container.scroll_horizontal, long_note_sprite.global_position.y)
			var scroll_end: Vector2 = Vector2(long_note_sprite.back.global_position.x + scroll_container.scroll_horizontal, long_note_sprite.back.global_position.y)
			
			if not _can_place_note(cell, scroll_end, NoteType.LONG):
				print("Can't place note in this position")
				return
			
			if is_lines_occupied(scroll_start, scroll_end):
				print("Nested long note inside")
				return
			
			if is_arrow_limit(cell, NoteType.LONG_DOUBLE_ARROW):
				print("Cannot add more arrow notes.")
				return
			
			if direction == GlobalSettings.Directions.NONE or direction_2 == GlobalSettings.Directions.NONE:
				print("One or two directions not selected.")
				return
			
			long_note_sprite.back_cell = cell
			#print("Cell %s" % grid.calculate_grid_coordinates_with_offset(long_note_sprite.back.global_position))
			note = ChartNote.new(beat, ChartNote.Note_Type.LONG_DOUBLE_ARROW, lane, direction, direction_2)
			long_note_sprite.set_arrow_direction(direction, direction_2)
			#_find_occupied_cells(long_note_sprite.front_cell, long_note_sprite.back_cell)
			_find_occupied_lines(long_note_sprite.global_position, long_note_sprite.back.global_position)
			_set_cells(cell, NoteType.LONG_DOUBLE_ARROW, long_note_sprite, note)
			
			if _ticks != 0:
				note.set_ticks(_ticks)
			
			if _note_position != Vector2.ZERO:
				long_note_sprite.back.global_position = _note_position
			
			note.set_position(long_note_sprite.back.global_position)
			
			_long_note = EnumLongNote.NONE


func _on_ui_editor_remove_note(cell: Vector2) -> void:
	if not is_occupied(cell):
		print("Nothing to remove")
		return
	
	var cell_to_remove: Dictionary = _find_note_in_cells(cell)
	
	print(cell_to_remove)
	
	#if _cells.has(cell):
	if not cell_to_remove.is_empty():
		
		#print(_cells.find_key(cell_to_remove[cell_to_remove.keys()[0]]))
		cell = cell_to_remove.keys()[0]
		
		
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
				_erase_occupied_lines(note_sprite_grid.global_position, note_sprite_grid.back.global_position)
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
	
	#print("Find occupied cells Start %s End %s" % [start, end])
	
	for i in range(start + 1, end):
		_occupied_cells_by_lines.append(Vector2(i, beginning_cell.y))


func _find_occupied_lines(start: Vector2, end: Vector2) -> void:
	if start.x < end.x and start.y == end.y:
		var scroll_start: Vector2 = Vector2(start.x + scroll_container.scroll_horizontal,start.y)
		var scroll_end: Vector2 = Vector2(end.x + scroll_container.scroll_horizontal, end.y)
		
		_occupied_cells_by_position.append([scroll_start, scroll_end])


func _find_note_in_cells(cell: Vector2) -> Dictionary:
	for _cell: Vector2 in _cells:
		
		var note_type: NoteType = _cells[_cell][Keys.NOTE_TYPE]
		var occupied_position: Vector2 = Vector2.ZERO
		
		match note_type:
			NoteType.LONG_BACK, NoteType.LONG_ARROW, NoteType.LONG_DOUBLE_ARROW:
				occupied_position = Vector2(_cells[_cell][Keys.SPRITE].back.global_position.x + scroll_container.scroll_horizontal, _cells[_cell][Keys.SPRITE].global_position.y)
				var occupied_cell: Vector2 = grid.calculate_grid_coordinates_with_offset(occupied_position)
				
				if cell == occupied_cell:
					var front_cell: Vector2 = _cells[_cell][Keys.SPRITE].front_cell
					
					return {_cell: _cells[front_cell]}
			
			_:
				occupied_position = Vector2(_cells[_cell][Keys.SPRITE].global_position.x + scroll_container.scroll_horizontal, _cells[_cell][Keys.SPRITE].global_position.y)
				var occupied_cell: Vector2 = grid.calculate_grid_coordinates_with_offset(occupied_position)
				
				if cell == occupied_cell:
					
					return {_cell: _cells[_cell]}
			
	return {}

func _erase_occupied_cells(beginning_cell: Vector2, end_cell: Vector2) -> void:
	var start = beginning_cell.x
	var end = end_cell.x
	
	for i in range(start + 1, end):
		_occupied_cells_by_lines.erase(Vector2(i, beginning_cell.y))


func _erase_occupied_lines(start: Vector2, end: Vector2) -> void:
	for array: Array in _occupied_cells_by_position:
		if array[OccupiedPositions.START] == start and array[OccupiedPositions.END] == end:
			_occupied_cells_by_position.erase(array)


func _add_long_back_note(cell: Vector2, note_type: NoteType, 
	direction: GlobalSettings.Directions=GlobalSettings.Directions.NONE, 
	direction_2: GlobalSettings.Directions=GlobalSettings.Directions.NONE,
	_note_position: Vector2=Vector2.ZERO, _ticks: int=0) -> void:
	
	if _long_note == EnumLongNote.BACK:
		var beat: float = float(cell.x) / GlobalSettings.beat_duration
		var lane: int = int(cell.y)
		var note: ChartNote
		match note_type:
			NoteType.LONG_BACK:
				#print("Cell %s" % grid.calculate_grid_coordinates_with_offset(long_note_sprite.back.global_position))
				note = ChartNote.new(beat, ChartNote.Note_Type.LONG_BACK, lane)
				
				print("Back")
				print("Cell %s" % cell)
				
				var sprite_position: Vector2 = grid.calculate_map_position_with_offset(cell)
				
				#print("Sprite position %s" % sprite_position)
				#print("Scroll container %s" % scroll_container.scroll_horizontal)
				
				long_note_sprite.back_cell = cell
				
				if _note_position != Vector2.ZERO:
					long_note_sprite.back.global_position = _note_position
				else:
					long_note_sprite.back.global_position.x = sprite_position.x - scroll_container.scroll_horizontal
				
				long_note_sprite.set_line_points()
				
				if _ticks != 0:
					note.set_ticks(_ticks)
				
				note.set_position(long_note_sprite.back.global_position)
				
				#_find_occupied_cells(long_note_sprite.front_cell, long_note_sprite.back_cell)
				_find_occupied_lines(long_note_sprite.global_position, long_note_sprite.back.global_position)
				_set_cells(cell, NoteType.LONG_BACK, long_note_sprite, note)
				_long_note = EnumLongNote.NONE
			NoteType.LONG_ARROW:
				if is_arrow_limit(cell, NoteType.LONG_ARROW):
					print("Cannot add more arrow notes.")
					return
				
				long_note_sprite.back_cell = cell
				note = ChartNote.new(beat, ChartNote.Note_Type.LONG_ARROW, lane, direction)
				var sprite_position: Vector2 = grid.calculate_map_position_with_offset(cell)
				
				#if _note_position != Vector2.ZERO:
					#print("Loaded position %s" % _note_position)
					#long_note_sprite.back.global_position = _note_position
				#else:
				long_note_sprite.back.global_position.x = sprite_position.x - scroll_container.scroll_horizontal
				
				long_note_sprite.set_line_points()
				
				if _ticks != 0:
					note.set_ticks(_ticks)
				
				note.set_position(long_note_sprite.back.global_position)
				
				long_note_sprite.set_arrow_direction(direction)
				#_find_occupied_cells(long_note_sprite.front_cell, long_note_sprite.back_cell)
				_find_occupied_lines(long_note_sprite.global_position, long_note_sprite.back.global_position)
				_set_cells(cell, NoteType.LONG_ARROW, long_note_sprite, note)
				_long_note = EnumLongNote.NONE
			NoteType.LONG_DOUBLE_ARROW:
				if is_arrow_limit(cell, NoteType.LONG_DOUBLE_ARROW):
					#print("Cannot add more arrow notes.")
					return
				
				long_note_sprite.back_cell = cell
				note = ChartNote.new(beat, ChartNote.Note_Type.LONG_DOUBLE_ARROW, lane, direction, direction_2)
				var sprite_position: Vector2 = grid.calculate_map_position_with_offset(cell)
				
				#if _note_position != Vector2.ZERO:
					##print("Loaded position %s" % _note_position)
					#long_note_sprite.back.global_position = _note_position
				#else:
				long_note_sprite.back.global_position.x = sprite_position.x - scroll_container.scroll_horizontal
				
				long_note_sprite.set_line_points()
				
				if _ticks != 0:
					note.set_ticks(_ticks)
				
				note.set_position(long_note_sprite.back.global_position)
				
				long_note_sprite.set_arrow_direction(direction, direction_2)
				#_find_occupied_cells(long_note_sprite.front_cell, long_note_sprite.back_cell)
				_find_occupied_lines(long_note_sprite.global_position, long_note_sprite.back.global_position)
				_set_cells(cell, NoteType.LONG_DOUBLE_ARROW, long_note_sprite, note)
				_long_note = EnumLongNote.NONE


func _can_place_note(cell: Vector2, note_position: Vector2, note_type: NoteType) -> bool:
	match note_type:
		NoteType.LONG, NoteType.LONG_BACK, NoteType.LONG_ARROW, NoteType.LONG_DOUBLE_ARROW:
			pass
		_:
			pass
			#note_position.x -= scroll_container.scroll_horizontal
	
	if is_occupied_position(note_position):
		print("Position is occupied %s" % note_position)
		return false
	
	var _cell = grid.calculate_grid_coordinates_with_offset(note_position)
	
	if is_occupied(_cell):
		print("Cell %s is occupied." % cell)
		return false
	
	if _occupied_cells_by_lines.has(cell):
		print("Cell %s is occupied by lines" % cell)
		return false
	
	if not grid.is_within_bounds(cell):
		print("Not inside grid bounds")
		return false
	
	return true


## Returns [code]true[/code] if [member _cells] contains [param cell].
func is_occupied(cell: Vector2) -> bool:
	var _position: Vector2 = grid.calculate_map_position_with_offset(cell)
	
	#print("cell %s" % cell)
	
	for _cell: Vector2 in _cells:
		
		var note_type: NoteType = _cells[_cell][Keys.NOTE_TYPE]
		var occupied_position: Vector2 = Vector2.ZERO
		
		match note_type:
			NoteType.LONG_BACK, NoteType.LONG_ARROW, NoteType.LONG_DOUBLE_ARROW:
				occupied_position = Vector2(_cells[_cell][Keys.SPRITE].back.global_position.x + scroll_container.scroll_horizontal, _cells[_cell][Keys.SPRITE].global_position.y)
			_:
				occupied_position = Vector2(_cells[_cell][Keys.SPRITE].global_position.x + scroll_container.scroll_horizontal, _cells[_cell][Keys.SPRITE].global_position.y)
		
		var occupied_cell: Vector2 = grid.calculate_grid_coordinates_with_offset(occupied_position)
		
		#print("_cell %s" % _cell)
		#print("Occupied cell %s" % occupied_cell)
		#print("Occupied position %s" % occupied_position)
		
		if cell == occupied_cell:
			#print("Found cell %s" % cell)
			
			return true
	
	return false
	#return _cells.has(cell)


## Returns [code]true[/code] if [member _occupied_cells_by_position] contains [param _position.x].
func is_occupied_position(_position: Vector2) -> bool:
	#print("Cell of picked position %s" % grid.calculate_grid_coordinates_with_offset(_position))
	#var temp_position: Vector2 = Vector2(_position.x + scroll_container.scroll_horizontal, _position.y)
	print("Real position %s" % _position)
	#print("Temp position %s" % temp_position)
	
	for array: Array in _occupied_cells_by_position:
		print("Array %s" % [array])
		
		if _position.x < array[OccupiedPositions.START].x:
			continue
		
		if array[OccupiedPositions.START].x < _position.x and _position.x < array[OccupiedPositions.END].x:
			if array[OccupiedPositions.START].y == _position.y:
				return true
	
	return false


func is_lines_occupied(_start_position: Vector2, _end_position: Vector2) -> bool:
	#_start_position = Vector2(_start_position.x + scroll_container.scroll_horizontal, _start_position.y)
	#_end_position = Vector2(_end_position.x + scroll_container.scroll_horizontal, _end_position.y)
	
	print("Start %s" % _start_position)
	print("End %s" % _end_position)
	
	for array: Array in _occupied_cells_by_position:
		#print("Array %s" % [array])
		
		#var temp_start: Vector2 = Vector2(array[OccupiedPositions.START].x + scroll_container.scroll_horizontal, array[OccupiedPositions.START].y)
		#var temp_end: Vector2 = Vector2(array[OccupiedPositions.END].x + scroll_container.scroll_horizontal, array[OccupiedPositions.END].y)
		
		if _start_position.x < array[OccupiedPositions.START].x and array[OccupiedPositions.END].x < _end_position.x:
			if array[OccupiedPositions.START].y == _start_position.y:
				return true
	
	return false


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
		var _position: Vector2 = _notes[cell][3]
		var _ticks: int = _notes[cell][4]
		
		#print("Note Type %s" % _note_type)
		#print("Position %s" % _position)
		
		
		match _note_type:
			NoteType.TAP:
				_on_ui_editor_add_tap_note(cell, _position, _ticks)
			NoteType.ARROW:
				var _direction: GlobalSettings.Directions = _notes[cell][1] as GlobalSettings.Directions
				
				_on_ui_editor_add_arrow_note(cell, _direction, _position, _ticks)
			NoteType.DOUBLE_ARROW:
				var _direction: GlobalSettings.Directions = _notes[cell][1] as GlobalSettings.Directions
				var _direction_2: GlobalSettings.Directions = _notes[cell][2] as GlobalSettings.Directions
				
				_on_ui_editor_add_double_arrow_note(cell, _direction, _direction_2, _position, _ticks)
			NoteType.LONG:
				_on_ui_editor_add_long_note(cell, _position, _ticks)
			NoteType.LONG_BACK:
				_add_long_back_note(cell, _note_type, GlobalSettings.Directions.NONE, GlobalSettings.Directions.NONE, _position, _ticks)
			NoteType.LONG_ARROW:
				var _direction: GlobalSettings.Directions = _notes[cell][1] as GlobalSettings.Directions
				
				var new_long_note_sprite: LongNoteArrowGridSprite = _long_note_arrow_grid_sprite_prefab.instantiate()
				
				_cells[long_note_sprite.front_cell][Keys.SPRITE] = new_long_note_sprite
				
				new_long_note_sprite.global_position = long_note_sprite.global_position
				new_long_note_sprite.front_cell = long_note_sprite.front_cell
				
				long_note_sprite.queue_free()
				
				long_note_sprite = new_long_note_sprite
				add_child(long_note_sprite)
				
				_add_long_back_note(cell, _note_type, _direction, GlobalSettings.Directions.NONE, _position, _ticks)
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
				
				_add_long_back_note(cell, _note_type, _direction, _direction_2, _position, _ticks)
	
	loading = false


## Remove all objects from NoteGrid.
func clear_grid() -> void:
	if not _cells.is_empty():
		
		for cell in _cells:
			#current_notes.remove_note(cell.x, _cells[cell][Keys.NOTE])
			_cells[cell][Keys.NOTE] = null
			_cells[cell][Keys.SPRITE].queue_free()
		
		_cells.clear()
		current_notes.clear()
		
		print("Cleared _cells")
		print(_cells)
	
	CLEARED.emit()
