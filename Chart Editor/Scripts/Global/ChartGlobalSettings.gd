extends Node

signal BPM_CHANGED(_bpm: float)
signal OFFSET_CHANGED(_offset: float)

enum Duration {
	NONE,
	#QUARTER = 1,
	#TRIPLET = 3,
	#EIGHTH = 2,
	SIXTEENTH = 4,
}

enum Directions {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	NONE,
}

const PPQ: int = 240

var bpm: float = 0.0:
	set(value):
		if bpm != value:
			bpm = value
			BPM_CHANGED.emit(bpm)
var beat_duration: Duration
var song_offset: float = 0.0:
	set(value):
		if song_offset != value:
			song_offset = value
			OFFSET_CHANGED.emit(song_offset)


func get_arrow_angle(direction: Directions) -> float:
	match direction:
		Directions.UP:
			return 0.0
		Directions.DOWN:
			return 180.0
		Directions.RIGHT:
			return 90.0
		Directions.LEFT:
			return 270.0
	
	return 0.0
