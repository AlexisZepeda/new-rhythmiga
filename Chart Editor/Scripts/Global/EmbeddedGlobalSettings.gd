extends Node

signal scroll_speed_changed(speed: float)

@export var use_filtered_playback: bool = true

@export var enable_input: bool = false
@export var enable_auto_input: bool = false
@export var enable_metronome: bool = false
@export var input_latency_ms: int = 20

@export var scroll_speed: float = 400:
	set(value):
		if scroll_speed != value:
			scroll_speed = value
			scroll_speed_changed.emit(value)

## Shortest duration of a beat. Based on BPM.
@export var sixteenth_duration: float = 0.0

var average_x_position: float = 0.0
var size: float = 0.0

var judgement_line: float = 0.0

func average_position() -> float:
	return average_x_position / size


func get_average_position(position_x) -> void:
	average_x_position += position_x
	size += 1
	print("Average position %s" % average_position())
