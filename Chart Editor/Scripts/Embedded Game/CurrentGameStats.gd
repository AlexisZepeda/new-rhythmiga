class_name CurrentGameStats
extends Resource

@export var perfect_count: int = 0:
	set(value):
		if perfect_count != value:
			perfect_count = value
			emit_changed()

@export var critical_count: int = 0:
	set(value):
		if critical_count != value:
			critical_count = value
			emit_changed()


@export var great_count: int = 0:
	set(value):
		if great_count != value:
			great_count = value
			emit_changed()

@export var good_count: int = 0:
	set(value):
		if good_count != value:
			good_count = value
			emit_changed()

@export var bad_count: int = 0:
	set(value):
		if bad_count != value:
			bad_count = value
			emit_changed()

@export var miss_count: int = 0:
	set(value):
		if miss_count != value:
			miss_count = value
			emit_changed()


func reset() -> void:
	perfect_count = 0
	critical_count = 0
	great_count = 0
	good_count = 0
	bad_count = 0
	miss_count = 0
