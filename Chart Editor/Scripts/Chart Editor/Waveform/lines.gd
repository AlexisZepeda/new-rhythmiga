class_name Lines
extends Control

signal IMAGE_LENGTH_CHANGED(length: int)

@export var lines_per_pixel: float
@export var beats: int
@export var quarter_beats: int
@export var cursor: Cursor
@export var beat_label_prefab: PackedScene
@export var grid: Grid

const COLUMNS: int = 4

const PIXELS_PER_QUARTER: int = 48
const PIXELS_PER_EIGHTH: int = 24
const PIXELS_PER_TRIPLET: int = 16
const PIXELS_PER_SIXTEENTH: int = 12

var _labels: Dictionary[int, BeatLabel] = {}

var image_length: int = 0
var line_length: float = self.size.y
var distance_between_lanes: float = 0:
	set(value):
		distance_between_lanes = value
		grid.offset = offset + distance_between_lanes

var offset: float = 50.0
var song_x_offset: float = 0.0

var lane_1_coordinates: Array[Vector2] = [Vector2(0, 50), Vector2(image_length, 50)]
var lane_2_coordinates: Array[Vector2] = [Vector2(0, 75), Vector2(image_length, 75)]
var lane_3_coordinates: Array[Vector2] = [Vector2(0, 100), Vector2(image_length, 100)]
var lane_4_coordinates: Array[Vector2] = [Vector2(0, 125), Vector2(image_length, 125)]
var lane_5_coordinates: Array[Vector2] = [Vector2(0, 150), Vector2(image_length, 150)]


func _draw() -> void:
	#grid.set_grid_size(Vector2(beats, COLUMNS))
	#grid.song_offset = song_x_offset
	#grid.set_cell_size(Vector2(lines_per_pixel, DISTANCE_BETWEEN_LANES))
	
	var line_coordinates: PackedVector2Array = []
	
	match GlobalSettings.beat_duration:
		GlobalSettings.Duration.TRIPLET:
			grid.set_cell_size(Vector2(PIXELS_PER_TRIPLET, distance_between_lanes))
		GlobalSettings.Duration.SIXTEENTH:
			grid.set_cell_size(Vector2(PIXELS_PER_SIXTEENTH, distance_between_lanes))
	
	
	# Draw Vertical beat lines
	for i in range(beats):
		
		var line_position_x: float = 0.0
		
		match GlobalSettings.beat_duration:
			#GlobalSettings.Duration.QUARTER:
				#grid.set_cell_size(Vector2(PIXELS_PER_QUARTER, DISTANCE_BETWEEN_LANES))
				#line_position_x = i * PIXELS_PER_QUARTER
				#
				#draw_line(Vector2(line_position_x, 0), Vector2(line_position_x, 200), Color.WHITE, 2)
				#
				#var label: Label = Label.new()
				#label.set_text(str(i + 1))
				#label.position.x = line_position_x + 2
				#
				#if get_child_count() > 0:
					#add_child(label)
			#GlobalSettings.Duration.EIGHTH:
				#grid.set_cell_size(Vector2(PIXELS_PER_EIGHTH, DISTANCE_BETWEEN_LANES))
				#line_position_x = i * PIXELS_PER_EIGHTH
				#
				#if i % 2 == 0:
					#draw_line(Vector2(line_position_x, 0), Vector2(line_position_x, 200), Color.WHITE, 2)
			GlobalSettings.Duration.TRIPLET:
				#grid.set_cell_size(Vector2(PIXELS_PER_TRIPLET, distance_between_lanes))
				line_position_x = i * PIXELS_PER_TRIPLET + song_x_offset
				
				if i % 3 == 0:
					var label_beat: int = int(i / 3.0) + 1
					
					if not _labels.has(label_beat):
					
						var label: BeatLabel = beat_label_prefab.instantiate()
						label.set_text(str(label_beat))
						label.position.x = line_position_x + 2
						
						if get_child_count() > 0:
							add_child(label)
						
						_labels[label_beat] = label
					else:
						var label: BeatLabel = _labels[label_beat]
						label.position.x = line_position_x + 2
					
					draw_line(Vector2(line_position_x, 0), Vector2(line_position_x, line_length), Color.WHITE, 2)
			#_:
			GlobalSettings.Duration.SIXTEENTH:
				#grid.set_cell_size(Vector2(PIXELS_PER_SIXTEENTH, distance_between_lanes))
				line_position_x = i * PIXELS_PER_SIXTEENTH + song_x_offset
				
				if i % 4 == 0:
					var label_beat: int = int(i / 4.0) + 1
					
					if not _labels.has(label_beat):
					
						var label: BeatLabel = beat_label_prefab.instantiate()
						label.set_text(str(label_beat))
						label.position.x = line_position_x + 2
						
						if get_child_count() > 0:
							add_child(label)
						
						_labels[label_beat] = label
					else:
						var label: BeatLabel = _labels[label_beat]
						label.position.x = line_position_x + 2
					
					draw_line(Vector2(line_position_x, 0), Vector2(line_position_x, line_length), Color.WHITE, 2)
		
		#var line_position_x: float = i * lines_per_pixel
		
		line_coordinates.append(Vector2(line_position_x, 0))
		line_coordinates.append(Vector2(line_position_x, line_length))
		
		#draw_line(Vector2(line_position_x, 0), Vector2(line_position_x, 512), Color.WHITE, 1)
	if not line_coordinates.is_empty():
		draw_multiline(line_coordinates, Color.WHITE, 1)
	
	# Draw Horizontal lane lines
	draw_line(lane_1_coordinates[0], lane_1_coordinates[1], Color.WHITE, 1.0)
	draw_line(lane_2_coordinates[0], lane_2_coordinates[1], Color.WHITE, 1.0)
	draw_line(lane_3_coordinates[0], lane_3_coordinates[1], Color.WHITE, 1.0)
	draw_line(lane_4_coordinates[0], lane_4_coordinates[1], Color.WHITE, 1.0)
	draw_line(lane_5_coordinates[0], lane_5_coordinates[1], Color.WHITE, 1.0)
	
	cursor.queue_redraw()


func _on_resized() -> void:
	line_length = size.y
	
	var cursor_size: float = int(line_length) - (offset * 2)
	distance_between_lanes = (cursor_size / 5.0)
	
	#print("Cursor size %s" % cursor_size)
	#print("Lane per size %s" % distance_between_lanes)
	
	lane_1_coordinates = [Vector2(0, offset + distance_between_lanes), Vector2(image_length, offset + distance_between_lanes)]
	lane_2_coordinates = [Vector2(0, offset + (distance_between_lanes * 2)), Vector2(image_length, offset + (distance_between_lanes * 2))]
	lane_3_coordinates = [Vector2(0, offset + (distance_between_lanes * 3)), Vector2(image_length, offset + (distance_between_lanes * 3))]
	lane_4_coordinates = [Vector2(0, offset + (distance_between_lanes * 4)), Vector2(image_length, offset + (distance_between_lanes * 4))]
	lane_5_coordinates = [Vector2(0, offset + (distance_between_lanes * 5)), Vector2(image_length, offset + (distance_between_lanes * 5))]
	
	var top_margin: float = offset + distance_between_lanes
	var bottom_margin: float = (distance_between_lanes * 4)
	
	cursor.resize(top_margin, bottom_margin)
	queue_redraw()


func set_lines() -> void:
	grid.set_grid_size(Vector2(beats, COLUMNS))
	grid.song_offset = song_x_offset
	
	grid.offset = offset + distance_between_lanes
	
	if image_length != roundi(PIXELS_PER_QUARTER * quarter_beats):
		image_length = roundi(PIXELS_PER_QUARTER * quarter_beats)
		IMAGE_LENGTH_CHANGED.emit(image_length)
	
	lane_1_coordinates[1] = Vector2(image_length, offset + distance_between_lanes)
	lane_2_coordinates[1] = Vector2(image_length, offset + (distance_between_lanes * 2))
	lane_3_coordinates[1] = Vector2(image_length, offset + (distance_between_lanes * 3))
	lane_4_coordinates[1] = Vector2(image_length, offset + (distance_between_lanes * 4))
	lane_5_coordinates[1] = Vector2(image_length, offset + (distance_between_lanes * 5))
	
	#self.size.x = image_length
	
	self.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	queue_redraw()
