class_name BeatLine
extends Line2D

@export_category("Conductor")
@export var conductor: Conductor

@export_category("Settings")
@export var x_offset: float = 400.0
@export var y_offset: float = 0.0
@export var beat: float = 0.0


var _speed: float
var _movement_paused: bool = false
var _song_time_delta: float = 0


func _init() -> void:
	_speed = EmbeddedGlobalSettings.scroll_speed


func _ready() -> void:
	EmbeddedGlobalSettings.scroll_speed_changed.connect(_on_scroll_speed_changed)


func _process(_delta: float) -> void:
	if _movement_paused:
		return
	
	_update_position()


func _update_position() -> void:
	if _song_time_delta > 0:
		# Slow the note down past the judgment line.
		position.x = (_speed * _song_time_delta - _speed * pow(_song_time_delta, 2)) + x_offset
	else:
		position.x = (_speed * _song_time_delta) + x_offset
	
	position.y = y_offset


func _on_scroll_speed_changed(speed: float) -> void:
	_speed = speed


func update_beat(curr_beat: float) -> void:
	_song_time_delta = (curr_beat - beat) * conductor.get_beat_duration()
	_update_position()
