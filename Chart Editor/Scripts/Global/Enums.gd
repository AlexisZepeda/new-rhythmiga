## Global enums.
class_name Enums

enum TimeType {
	FILTERED,
	RAW,
}


enum Hit_Type {
	PERFECT,
	CRITICAL,
	GREAT,
	GOOD,
	BAD,
	MISS,
}


## Four cardinal directions of a slide.
enum Direction { 
	UP = 0, 
	DOWN = 1, 
	LEFT = 2, 
	RIGHT = 3,
}


enum Note_Type {
	TAP,
	SLIDE,
	DOUBLE_SLIDE,
	LONG,
	LONG_BACK,
	LONG_SLIDE,
	LONG_DOUBLE_SLIDE,
	NONE,
}


enum Joy_Axis { 
	JOY_AXIS_RIGHT, 
	JOY_AXIS_LEFT,
}

enum Duration {
	QUARTER = 1,
	EIGHTH = 2,
	TRIPLET = 3,
	SIXTEENTH = 4,
}
