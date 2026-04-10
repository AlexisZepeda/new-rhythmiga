class_name GameUI
extends Control

@export var rhythm_game: RhythmGame
@export var timing_label_prefab: PackedScene
@export var song_progress_bar: ProgressBar

@export var song_name: SongPanel
@export var score_label: Label

const LABEL_X_OFFSET: float = 15.0
const PERFECT: String = "Perfect"
const CRITICAL: String = "Critical"
const GREAT: String = "Great"
const GOOD: String = "Good"
const BAD: String = "Bad"
const MISS: String = "Miss"

var song_length: float = 0.0



func _ready() -> void:
	rhythm_game.conductor.loaded_new_stream.connect(_on_loaded_new_stream)
	rhythm_game.play_stats.changed.connect(_on_play_stats_changed)
	
	song_name.visible = false
	
	if rhythm_game.conductor.stream != null:
		song_length = rhythm_game.conductor.stream.get_length()
	
	#song_name.set_text(CustomMusicManager.library[CustomMusicManager.current_id][CustomMusicManager.Library_Keys.SONG_NAME])


func _process(_delta: float) -> void:
	song_progress_bar.value = rhythm_game.conductor.get_playback_position() / song_length


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
	if rhythm_game.conductor.stream != null:
		song_length = rhythm_game.conductor.stream.get_length()
	#song_progress_bar.max_value = rhythm_game.conductor.stream.get_length()


func _on_play_stats_changed() -> void:
	score_label.set_score(rhythm_game.play_stats.target_score)
	
	#score_label.set_text(str(rhythm_game.play_stats.target_score))


func init_game_signals(note_manager: NoteManager) -> void:
	note_manager.note_hit_type.connect(_on_hit_type)


func set_song_panel() -> void:
	song_name.visible = true
	song_name.set_info()
