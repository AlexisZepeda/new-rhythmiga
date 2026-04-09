class_name CurrentGameStats
extends Resource


const TOTAL_SCORE: int = 9999999
const TOTAL_JUDGMENT_SCORE: int = 7500000
const TOTAL_CHAIN_SCORE: int = 2500000


@export var perfect_count: int = 0:
	set(value):
		if perfect_count != value:
			perfect_count = value
			combo += 1
			perfect_score = ratio_of_judgment_score * perfect_count
			_update_score()
			emit_changed()

@export var critical_count: int = 0:
	set(value):
		if critical_count != value:
			critical_count = value
			combo += 1
			critical_score = ratio_of_judgment_score * (critical_count * (13.0 / 15.0))
			_update_score()
			emit_changed()


@export var great_count: int = 0:
	set(value):
		if great_count != value:
			great_count = value
			combo += 1
			great_score = ratio_of_judgment_score * (great_count * (1.0 / 3.0))
			_update_score()
			emit_changed()

@export var good_count: int = 0:
	set(value):
		if good_count != value:
			good_count = value
			combo += 1
			good_score = ratio_of_judgment_score * (good_count * (1.0 / 12.0))
			_update_score()
			emit_changed()

@export var bad_count: int = 0:
	set(value):
		if bad_count != value:
			bad_count = value
			combo = 0
			_update_score()
			emit_changed()

@export var miss_count: int = 0:
	set(value):
		if miss_count != value:
			miss_count = value
			combo = 0
			_update_score()
			emit_changed()

var total_notes: int = 0:
	set(value):
		if value >= 0:
			total_notes = value
			ratio_of_judgment_score = ceil(float(TOTAL_JUDGMENT_SCORE) / total_notes)
			ratio_of_chain_score = ceil(float(TOTAL_CHAIN_SCORE) / (total_notes - 13))

var ratio_of_judgment_score: float = 0# = ceil(float(TOTAL_JUDGMENT_SCORE) / NoteDictionaryReader.size)
var ratio_of_chain_score: float = 0# = ceil(float(TOTAL_CHAIN_SCORE) / (NoteDictionaryReader.size - 13))

var max_combo: int = 0
var combo: int = 0

var target_score: int = 0
var chain_score: float = 0
var good_score: float = 0
var great_score: float = 0
var critical_score: float = 0
var perfect_score: float = 0


func _update_score() -> void:
	if combo < 24:
		chain_score += ratio_of_chain_score * (combo * 0.04)
	else:
		chain_score += ratio_of_chain_score * (25 * 0.04)
	
	target_score = ceil(good_score + great_score + critical_score + perfect_score) + ceil(chain_score)
	
	if target_score > TOTAL_SCORE:
		target_score = TOTAL_SCORE
	
	if combo > max_combo:
		max_combo = combo


func reset() -> void:
	perfect_count = 0
	critical_count = 0
	great_count = 0
	good_count = 0
	bad_count = 0
	miss_count = 0
	
	max_combo = 0
	combo = 0
	
	target_score = 0
	chain_score = 0
	good_score = 0
	great_score = 0
	critical_score = 0
	perfect_score = 0
