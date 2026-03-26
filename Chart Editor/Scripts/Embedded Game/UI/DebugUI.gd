extends Control

@export_category("Children")
@export_group("Note Deltas")
@export var label_1: Label
@export var label_2: Label
@export var label_3: Label
@export var label_4: Label
@export var label_5: Label
@export var label_beat: Label
@export_group("")

@export_group("Queue")
@export var queue_front: Label
@export var queue_2: Label
@export var queue_3: Label
@export var queue_end: Label
@export_group("")

@export_group("Keys")
@export var label_e: Label
@export var label_f: Label
@export var label_i: Label
@export var label_j: Label

@export_group("Hit Type Count")
@export var perfect: Label
@export var critical: Label
@export var great: Label
@export var good: Label
@export var bad: Label
@export var miss: Label

@export_category("Dependencies")
#@export var conductor: Conductor
@onready var rhythm_game: RhythmGame = $"../.."


func set_note_delta_labels(note_delta: float, note_delta_2: float, note_delta_3: float, note_delta_4: float) -> void:
	label_1.set_text("ND NM1 %s" % str(note_delta))
	label_2.set_text("ND NM2 %s" % str(note_delta_2))
	label_3.set_text("ND NM3 %s" % str(note_delta_3))
	label_4.set_text("ND NM4 %s" % str(note_delta_4))
	label_beat.set_text("Beat %s" % str(rhythm_game.conductor.get_current_beat()))


func print_queue(queue: PriorityQueue) -> void:
	label_5.set_text("%s" % queue.print_front())
	var array = queue.print_queue()
	
	if not array.is_empty():
		for i in range(array.size()):
			match i:
				0:
					queue_front.set_text(str(array.get(0)))
				1:
					queue_2.set_text(str(array.get(1)))
				2:
					queue_3.set_text(str(array.get(2)))
				3:
					queue_end.set_text(str(array.get(3)))


func print_keys(e: bool, f: bool, i: bool, j: bool) -> void:
	label_e.set_text("E %s" % str(e))
	label_f.set_text("F %s" % str(f))
	label_j.set_text("J %s" % str(j))
	label_i.set_text("I %s" % str(i))


func _on_notes_play_stats_updated(_play_stats: CurrentGameStats) -> void:
	perfect.set_text("Perfect %s" % _play_stats.perfect_count)
	critical.set_text("Critical %s" % _play_stats.critical_count)
	great.set_text("Great %s" % _play_stats.great_count)
	good.set_text("Good %s" % _play_stats.good_count)
	bad.set_text("Bad %s" % _play_stats.bad_count)
	miss.set_text("Miss %s" % _play_stats.miss_count)
