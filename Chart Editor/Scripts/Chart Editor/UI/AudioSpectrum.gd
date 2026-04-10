class_name AudioSpectrumAnalyzer
extends MarginContainer

@export_category("Nodes")
@export var rhythm_game: RhythmGame
@export var metronome: AudioStreamPlayer
@export var player: ChartConductor
@export_group("UI")
@export var timeline_texture: RMAudioStreamEditor
@export var scroll_container: ScrollContainer
@export var option_menu: OptionButton
@export var spinbox_bpm: SpinBox
@export var offset_line_edit: LineEdit
@export var time_graph: Control
@export var lines: Lines

@export_category("Parameters")
@export var bpm: float = 100.0: set = set_bpm
@export var beat_duration: GlobalSettings.Duration: set = set_beat_duration
@export var offset: String = "": set = set_song_offset

const IMAGE_LENGTH: int = 30000
var image_length: int = 0
var song_length: float = 0.0
## Song length after offset.
var playable_song_length: float = 0

#how many secunds per pixel
var _song_position_offset: float = 0.0

# For mouse hover
var _seconds_per_pixel: float = 0.0
var _seek: float = 0.0

var lines_per_pixel: float = 0.0:
	set(value):
		if is_inf(value):
			lines_per_pixel = 0
		else:
			lines_per_pixel = value
var beats: int = 0:
	set(value):
		if is_inf(value):
			beats = 0
		else:
			beats = value
var duration: float = 0.0:
	set(value):
		if is_inf(value):
			duration = 0
		else:
			duration = value
var quarter_beats: int = 0:
	set(value):
		if is_inf(value):
			quarter_beats = 0
		else:
			quarter_beats = value
var song_offset: float = 0.0
var mouse_position: Vector2 = Vector2.ZERO

var is_hover: bool = false

var format_string: String = "%.3f" 


# Called when the node enters the scene tree for the first time.
func _ready():
	if player.stream != null:
		song_length = player.stream.get_length()
	#print("song length %s" % song_length)
	set_song_offset(offset)
	
	#option_menu.clear()
	#
	#for i in GlobalSettings.Duration.keys():
		#if i == GlobalSettings.Duration.keys()[GlobalSettings.Duration.NONE]:
			#continue
		#
		#option_menu.add_item(i, GlobalSettings.Duration[i])
	#
	#option_menu.select(GlobalSettings.Duration.size() - 2)
	
	spinbox_bpm.value = bpm
	rhythm_game.init_rhythm_game(RhythmGame.Game_Version.CHART_EDITOR)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	time_graph.queue_redraw()


func _on_option_button_item_selected(index: int) -> void:
	var id = option_menu.get_item_id(index)
	var _value = GlobalSettings.Duration.find_key(id)
	
	set_beat_duration(id)


func _on_play_pressed() -> void:
	play(_seek)


func _on_pause_pressed() -> void:
	EmbeddedGlobalSettings.enable_input = false
	player.pause_conductor()


func _on_stop_pressed() -> void:
	_seek = 0.0
	EmbeddedGlobalSettings.enable_input = false
	player.stop_conductor()
	metronome.reset()
	rhythm_game.reset()


func _on_spin_box_value_changed(value: float) -> void:
	set_bpm(value)
	set_beat_duration(beat_duration)


func _on_offset_value_changed(new_text: String) -> void:
	offset = new_text


func _on_lines_image_length_changed(length: int) -> void:
	image_length = length
	
	timeline_texture.custom_minimum_size.x = image_length
	timeline_texture.start_point = 0.0
	timeline_texture.end_point = player.stream.get_length()
	timeline_texture.rms_size_multiplier = 2.0
	timeline_texture.edit(player.stream)
	
	_seconds_per_pixel = playable_song_length / image_length
	_song_position_offset = song_offset / _seconds_per_pixel
	
	#print("offset length %s" % (song_offset / _seconds_per_pixel))


func _on_time_graph_draw() -> void:
	if player.playing:
		#var song_beats = quarter_beats
		#var curr_beat = clampf(player.get_current_beat() / Enums.Duration.SIXTEENTH, 0, song_beats)
		#var time_x: float = remap(curr_beat, 0, song_beats, 0, time_graph.size.x)
		#
		#time_graph.draw_line(Vector2(time_x, 0), Vector2(time_x, time_graph.size.y), Color.RED, 2)
		
		var progress: float = player.get_playback_position()
		var time_x: float = (progress / song_length) * time_graph.size.x
		
		time_graph.draw_line(Vector2(time_x, 0), Vector2(time_x, time_graph.size.y), Color.RED, 2)
		
		if time_x > get_rect().end.x + scroll_container.scroll_horizontal:
			scroll_container.scroll_horizontal += int(get_rect().end.x * 0.75)
	
	if is_hover:
		time_graph.draw_line(Vector2(mouse_position.x, 0), Vector2(mouse_position.x, time_graph.size.y), Color.BLUE, 2)


func _on_conductor_loaded_new_stream() -> void:
	song_length = player.stream.get_length()
	
	set_song_offset(offset)
	
	timeline_texture.custom_minimum_size.x = image_length
	timeline_texture.start_point = 0.0
	timeline_texture.end_point = player.stream.get_length()
	timeline_texture.rms_size_multiplier = 2.0
	timeline_texture.edit(player.stream)


func _on_conductor_finished() -> void:
	_seek = 0.0


func play(time:float):
	if time == 0.0:
		rhythm_game.reset()
	
	EmbeddedGlobalSettings.enable_input = true
	player.play_conductor(time)
	metronome.start()


func set_lines() -> void:
	lines.lines_per_pixel = lines_per_pixel
	lines.beats = beats
	lines.quarter_beats = quarter_beats
	lines.song_x_offset = _song_position_offset
	lines.set_lines()


func set_bpm(value) -> void:
	if value > 522:
		bpm = 522
	elif value < 0:
		bpm = 0
	else:
		bpm = value
	
	if not player:
		await self.ready
	
	set_beat_duration(beat_duration)
	
	GlobalSettings.bpm = bpm
	
	beats = int(playable_song_length / duration)
	
	## TOTAL QUARTER BEATS
	quarter_beats = int(playable_song_length / (60.0 / bpm))
	
	lines_per_pixel = float(IMAGE_LENGTH) / beats
	
	#print("Duration %s" % duration)
	#print("Beats %s" % beats)
	#print("Lines per pixel %s" % lines_per_pixel)
	
	set_lines()


func set_beat_duration(value: GlobalSettings.Duration) -> void:
	beat_duration = value
	
	if not player:
		await self.ready
	
	GlobalSettings.beat_duration = beat_duration
	
	## TOTAL BEATS BASED ON BEAT DURATION
	duration = 60.0 / bpm / beat_duration
	
	beats = int(playable_song_length / duration)
	
	## TOTAL QUARTER BEATS
	quarter_beats = int(playable_song_length / (60.0 / bpm))
	
	lines_per_pixel = float(IMAGE_LENGTH) / beats
	
	set_lines()


func set_song_offset(value: String) -> void:
	if offset_line_edit == null:
		await self.ready
	
	offset = value
	
	if offset.is_valid_float():
		var new_value: float = type_convert(offset, TYPE_FLOAT)
		
		if new_value < 0.0:
			song_offset = 0.0
		elif new_value < song_length:
			song_offset = new_value
			
			playable_song_length = song_length - song_offset
			
			_song_position_offset = song_offset / _seconds_per_pixel
			set_bpm(bpm)
		else:
			song_offset = 0.0
		
		GlobalSettings.song_offset = song_offset
		offset_line_edit.text = str(song_offset)


func hover_time_graph_line(_mouse_position: Vector2) -> void:
	if player.stream != null:
		
		is_hover = true
		
		mouse_position = _mouse_position
		time_graph.queue_redraw()


func clear_hover_time_graph_line() -> void:
	if player.stream != null:
		is_hover = false
		
		mouse_position = Vector2(-1, -1)
		time_graph.queue_redraw()


func seek_seconds() -> void:
	_seek = _seconds_per_pixel * mouse_position.x
	
	print("Seek Seconds %s" % [_seek])
	
	play(_seek)
