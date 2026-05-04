class_name NewNoteGrid
extends Control

signal LONG_NOTE_SET

@export var grid: Grid
@export var current_notes: CurrentNotes

@export_group("Notes")
@export var tap_note_prefab: PackedScene
@export var slide_note_prefab: PackedScene
@export var _long_note_grid_sprite_prefab: PackedScene
@export_group("")

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


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var cell: Vector2 = grid.calculate_grid_coordinates_with_offset(at_position)
	var cell_position: Vector2 = grid.calculate_map_position_with_offset(cell)
	
	if is_empty(cell_position) and data is NoteDrag:
		return true
	else:
		return false


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var cell: Vector2 = grid.calculate_grid_coordinates_with_offset(at_position)
	var cell_position: Vector2 = grid.calculate_map_position_with_offset(cell)
	
	remove_cell(data.mouse_position, NoteType.TAP)
	
	if data is NoteDrag:
		match data.note_type:
			NoteType.TAP:
				add_tap_note(cell, cell_position)


## Adds a [ControlNoteGridSprite] to the [NewNoteGrid].
func add_tap_note(cell: Vector2, mouse_position: Vector2) -> void:
	if not is_empty(mouse_position):
		print("_cells has a note in %s position" % mouse_position)
		return
	
	print("Added tap note at position %s" % mouse_position)
	
	var beat: float = float(cell.x) / GlobalSettings.beat_duration
	var lane: int = int(cell.y)
	
	var tap_note: ControlNoteGridSprite = create_texture_rect_note(mouse_position, NoteType.TAP)
	
	var note: ChartNote = ChartNote.new(beat, ChartNote.Note_Type.TAP, lane)
	set_cell(tap_note, mouse_position, NoteType.TAP, note)

## Adds a [ControlNoteGridSprite] to the [NewNoteGrid].
func add_slide_note(cell: Vector2, mouse_position: Vector2) -> void:
	if not is_empty(mouse_position):
		print("_cells has a note in %s position" % mouse_position)
		return
	
	print("Added tap note at position %s" % mouse_position)
	
	var beat: float = float(cell.x) / GlobalSettings.beat_duration
	var lane: int = int(cell.y)
	var note_type: NoteType = NoteType.ARROW
	
	
	var slide_note: ControlNoteGridSprite = create_texture_rect_note(mouse_position, note_type)
	
	var note: ChartNote = ChartNote.new(beat, ChartNote.Note_Type.ARROW, lane)
	set_cell(slide_note, mouse_position, note_type, note)


func clear_grid() -> void:
	pass


func create_texture_rect_note(mouse_position: Vector2, note_type: NoteType) -> TextureRect:
	var texture_rect: TextureRect = null
	
	match note_type:
		NoteType.TAP:
			var tap_note: ControlNoteGridSprite = tap_note_prefab.instantiate()
			tap_note.position = mouse_position
			tap_note.mouse_position = mouse_position
			add_child(tap_note)
			
			texture_rect = tap_note
	
	return texture_rect


## Returns [member true] if [member _cells] does not have a key at [param mouse_position].
func is_empty(mouse_position: Vector2) -> bool:
	if _cells.has(mouse_position):
		return false
	else:
		return true


func load_notes(_notes: Dictionary) -> void:
	pass


func remove_cell(mouse_position: Vector2, note_type: NoteType) -> void:
	if is_empty(mouse_position):
		print("Nothing to remove at %s" % mouse_position)
		return
	
	var cell: Array = _cells[mouse_position]
	cell[Keys.SPRITE].queue_free()
	_cells.erase(mouse_position)


func set_cell(sprite: TextureRect, mouse_position: Vector2, note_type: NoteType, note: ChartNote) -> void:
	if _cells.has(mouse_position):
		return
	
	_cells.set(mouse_position, [note_type, sprite, note])
