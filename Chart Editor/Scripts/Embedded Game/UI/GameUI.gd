class_name GameUI
extends Control

@export var rhythm_game: RhythmGame
@export var timing_label_prefab: PackedScene
@export var song_progress_bar: ProgressBar

@export var song_name: SongPanel
@export var chain_label: Label
@export var score_label: Label

@export var start_label: PackedScene
@export var finish_label: PackedScene

const LABEL_X_OFFSET: float = 15.0
const PERFECT: String = "Perfect"
const CRITICAL: String = "Critical"
const GREAT: String = "Great"
const GOOD: String = "Good"
const BAD: String = "Bad"
const MISS: String = "Miss"

var song_length: float = 0.0



func _ready() -> void:
	rhythm_game.shinobu_conductor.loaded_new_stream.connect(_on_loaded_new_stream)
	rhythm_game.play_stats.changed.connect(_on_play_stats_changed)
	
	song_name.visible = false
	
	#if rhythm_game.conductor.stream != null:
		#song_length = rhythm_game.conductor.stream.get_length()
	
	if not rhythm_game.shinobu_conductor.is_empty():
		song_length = rhythm_game.shinobu_conductor.get_length()
	
	#song_name.set_text(CustomMusicManager.library[CustomMusicManager.current_id][CustomMusicManager.Library_Keys.SONG_NAME])


func _process(_delta: float) -> void:
	song_progress_bar.value = rhythm_game.shinobu_conductor.get_playback_position() / song_length


func _on_hit_type(hit_type: Enums.Hit_Type, label_position: Vector2) -> void:
	var timing_label: TimingLabelPrefab = timing_label_prefab.instantiate()
	add_child(timing_label)
	timing_label.position = label_position
	timing_label.position.x = label_position.x + LABEL_X_OFFSET
	
	match hit_type:
		Enums.Hit_Type.PERFECT:
			timing_label.add_text(PERFECT)
		Enums.Hit_Type.CRITICAL:
			timing_label.add_text(CRITICAL)
		Enums.Hit_Type.GREAT:
			timing_label.add_text(GREAT)
		Enums.Hit_Type.GOOD:
			timing_label.add_text(GOOD)
		Enums.Hit_Type.BAD:
			timing_label.add_text(BAD)
		Enums.Hit_Type.MISS:
			timing_label.add_text(MISS)


func _on_loaded_new_stream() -> void: 
	if not rhythm_game.shinobu_conductor.is_empty():
		song_length = rhythm_game.shinobu_conductor.get_length()
	#song_progress_bar.max_value = rhythm_game.conductor.stream.get_length()


func _on_play_stats_changed() -> void:
	score_label.set_score(rhythm_game.play_stats.target_score)
	set_chain()
	#score_label.set_text(str(rhythm_game.play_stats.target_score))


func init_game_signals(note_manager: NoteManager) -> void:
	note_manager.note_hit_type.connect(_on_hit_type)


func set_song_panel() -> void:
	song_name.visible = true
	song_name.set_info()


func set_chain() -> void:
	var combo: int = rhythm_game.play_stats.combo
	
	if combo == 0:
		chain_label.visible = false
	else:
		chain_label.visible = true
	
	var chain: String = "%s chain" % rhythm_game.play_stats.combo
	
	chain_label.set_text(chain)


func start_animation() -> void:
	var start: StartLabel = start_label.instantiate()
	
	add_child(start)
	
	await start.start_anim()
	
	start.queue_free()


func finish_animation() -> void:
	var finish: FinishLabel = finish_label.instantiate()
	
	add_child(finish)
	
	await finish.start_anim()
	
	finish.queue_free()
