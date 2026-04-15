class_name Note
extends Node2D

signal note_hit(hit_type: Enums.Hit_Type)

@export_category("Conductor")
@export var conductor: ShinobuConductor

@export_category("Settings")
@export var x_offset: float = EmbeddedGlobalSettings.judgement_line#1620#400.0
@export var y_offset: float = 0.0
@export var beat: float = 0.0
@export var tick: float = 0.0

@export_category("Children")
@export var base_sprite: Sprite2D

const HIT_MARGIN_PERFECT = 0.016667
const HIT_MARGIN_CRITICAL = 0.033333
const HIT_MARGIN_GREAT = 0.050
const HIT_MARGIN_GOOD = 0.100
const HIT_MARGIN_BAD = 0.13333
const HIT_MARGIN_MISS = 0.200

var _speed: float
var _movement_paused: bool = false
var _song_time_delta: float = 0

var held: bool = false


func _init() -> void:
	_speed = EmbeddedGlobalSettings.scroll_speed


func _ready() -> void:
	EmbeddedGlobalSettings.scroll_speed_changed.connect(_on_scroll_speed_changed)


func _process(_delta: float) -> void:
	if _movement_paused:
		return
	
	_update_position()
	
	#if -HIT_MARGIN_PERFECT <= _song_time_delta and _song_time_delta <= HIT_MARGIN_PERFECT:
		## Hit on time, perfect.
		#print_rich("	[color=yellow]Perfect[/color]")
		#hit_perfect()


func _update_position() -> void:
	if _song_time_delta > 0:
		# Slow the note down past the judgment line.
		position.x = (_speed * _song_time_delta - _speed * pow(_song_time_delta, 2)) + x_offset
	else:
		position.x = (_speed * _song_time_delta) + x_offset
	
	position.y = y_offset


func _on_scroll_speed_changed(speed: float) -> void:
	_speed = speed


func _get_average_position() -> void:
	EmbeddedGlobalSettings.get_average_position(position.x)


func update_beat(curr_beat: float) -> void:
	_song_time_delta = (curr_beat - beat) * conductor.get_beat_duration()
	_update_position()


func update_tick(curr_tick: float) -> void:
	_song_time_delta = (curr_tick - tick) * conductor.get_ppq_duration()
	#print("Curr tick %s" % curr_tick)
	#print("Tick %s" % tick)
	#print("Delta %s" % _song_time_delta)
	_update_position()


func hit_perfect() -> void:
	_movement_paused = true
	
	#GlobalSettings.get_average_position(self.position.x)

	modulate = Color.YELLOW
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.2)
	tween.parallel().tween_property(base_sprite, ^"scale", 1.5 * Vector2.ONE, 0.2)
	tween.tween_callback(queue_free)
	
	note_hit.emit(Enums.Hit_Type.PERFECT)


func hit_critical() -> void:
	_movement_paused = true
	
	#GlobalSettings.get_average_position(self.position.x)

	modulate = Color.ORANGE_RED
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.2)
	tween.parallel().tween_property(base_sprite, ^"scale", 1.5 * Vector2.ONE, 0.2)
	tween.tween_callback(queue_free)
	
	note_hit.emit(Enums.Hit_Type.CRITICAL)


func hit_great() -> void:
	_movement_paused = true

	modulate = Color.FOREST_GREEN

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.2)
	tween.parallel().tween_property(base_sprite, ^"scale", 1.2 * Vector2.ONE, 0.2)
	tween.tween_callback(queue_free)
	
	note_hit.emit(Enums.Hit_Type.GREAT)


func hit_good() -> void:
	_movement_paused = true

	modulate = Color.DEEP_SKY_BLUE

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.2)
	tween.parallel().tween_property(base_sprite, ^"scale", 1.2 * Vector2.ONE, 0.2)
	tween.tween_callback(queue_free)
	
	note_hit.emit(Enums.Hit_Type.GOOD)


func hit_bad(stop_movement: bool = true) -> void:
	_movement_paused = stop_movement

	modulate = Color.PURPLE

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.2)
	tween.parallel().tween_property(base_sprite, ^"scale", 1.2 * Vector2.ONE, 0.2)
	tween.tween_callback(queue_free)
	
	note_hit.emit(Enums.Hit_Type.BAD)


func miss(stop_movement: bool = true) -> void:
	_movement_paused = stop_movement
	
	modulate = Color.DARK_RED
	
	var tween := create_tween()
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.5)
	tween.tween_callback(queue_free)
	
	note_hit.emit(Enums.Hit_Type.MISS)


func evaluate(param_delta: float) -> bool:
	var hit_delta: float = param_delta
	if hit_delta < -HIT_MARGIN_MISS:
		# Note is not hittable, do nothing.
		print("	Not hittable %s" % hit_delta)
		return false
	elif -HIT_MARGIN_PERFECT <= hit_delta and hit_delta <= HIT_MARGIN_PERFECT:
		# Hit on time, perfect.
		print_rich("	[color=yellow]Perfect[/color]")
		hit_perfect()
		return true
	elif -HIT_MARGIN_CRITICAL <= hit_delta and hit_delta <= HIT_MARGIN_CRITICAL:
		print_rich("	[color=orange]Critical[/color]")
		hit_critical()
		return true
	elif -HIT_MARGIN_GREAT <= hit_delta and hit_delta <= HIT_MARGIN_GREAT:
		print_rich("	[color=green]Great[/color]")
		hit_great()
		return true
	elif -HIT_MARGIN_GOOD <= hit_delta and hit_delta <= HIT_MARGIN_GOOD:
		# Hit slightly off time, good.
		print_rich("	[color=blue]Good[/color]")
		hit_good()
		return true
		#if hit_delta < 0:
			#note_hit.emit(note.beat, Enums.HitType.GOOD_EARLY, hit_delta)
		#else:
			#note_hit.emit(note.beat, Enums.HitType.GOOD_LATE, hit_delta)
	elif -HIT_MARGIN_BAD <= hit_delta and hit_delta <= HIT_MARGIN_BAD:
		hit_bad()
		return true
	elif -HIT_MARGIN_MISS <= hit_delta and hit_delta <= HIT_MARGIN_MISS:
		# Hit way off time, miss.
		print("Note Miss")
		miss()
		return true
		#if hit_delta < 0:
			#note_hit.emit(note.beat, Enums.HitType.MISS_EARLY, hit_delta)
		#else:
			#note_hit.emit(note.beat, Enums.HitType.MISS_LATE, hit_delta)
	
	print("Failed all conditionals")
	return false
