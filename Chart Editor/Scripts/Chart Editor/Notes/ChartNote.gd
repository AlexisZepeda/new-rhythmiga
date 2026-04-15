class_name ChartNote

enum Note_Type {
	TAP,
	ARROW,
	DOUBLE_ARROW,
	LONG,
	LONG_BACK,
	LONG_ARROW,
	LONG_DOUBLE_ARROW,
}

var _ticks: int
var _time: float
var beat: float
var type: Note_Type
var lane: int
var direction: int
var direction_2: int


func _init(_beat: float, _type: Note_Type, _lane: int, _direction:int=4, _direction_2:int=4) -> void:
	beat = _beat
	type = _type
	lane = _lane
	direction = _direction
	direction_2 = _direction_2
	
	_ticks = calculate_ticks()
	_time = calculate_seconds()
	
	
	var note_type: String = Note_Type.keys()[type]
	print("Created %s note at %s beat with %s ticks and time %s(secs)." % [note_type, beat, _ticks, _time])


func calculate_ticks() -> int:
	return int(beat * GlobalSettings.PPQ)


## Calculates the metric time (seconds) of the note based on the BPM and PPQ.
## In case of tempo changes the most recent BPM before the note must be used.
func calculate_seconds() -> float:
	#print("PPQ duration %s" % [60000 / (GlobalSettings.bpm * GlobalSettings.PPQ)])
	var seconds_per_tick: float = 60000 / (GlobalSettings.bpm * GlobalSettings.PPQ) / 1000
	
	return _ticks * seconds_per_tick
