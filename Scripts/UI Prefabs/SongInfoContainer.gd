class_name SongInfoContainer
extends MarginContainer

signal difficulty_changed(_difficulty: Enums.Difficulty)

@export var album_art: TextureRect
@export var song_artist: Label
@export var song_title: Label
@export var score: Label

@export_group("Buttons")
@export var easy_btn: Button
@export var medium_btn: Button
@export var hard_btn: Button
@export_group("")

var difficulty: Enums.Difficulty


func _ready() -> void:
	easy_btn.pressed.connect(_on_easy_pressed)
	medium_btn.pressed.connect(_on_medium_pressed)
	hard_btn.pressed.connect(_on_hard_pressed)
	
	_set_difficulty_pressed()
	
	await appear_anim()


func _on_easy_pressed() -> void:
	difficulty = Enums.Difficulty.EASY
	difficulty_changed.emit(difficulty)


func _on_medium_pressed() -> void:
	difficulty = Enums.Difficulty.MEDIUM
	difficulty_changed.emit(difficulty)


func _on_hard_pressed() -> void:
	difficulty = Enums.Difficulty.HARD
	difficulty_changed.emit(difficulty)


func _set_difficulty_pressed() -> void:
	difficulty = CustomMusicManager.current_difficulty
	
	match difficulty:
		Enums.Difficulty.EASY:
			easy_btn.button_pressed = true
		Enums.Difficulty.MEDIUM:
			medium_btn.button_pressed = true
		Enums.Difficulty.HARD:
			hard_btn.button_pressed = true


func appear_anim() -> void:
	var mod_tween: Tween = create_tween()
	
	mod_tween.tween_property(self, "modulate:a", 1.0, 1.0)
	
	await mod_tween.finished


func disappear_anim() -> void:
	var mod_tween: Tween = create_tween()
	
	mod_tween.tween_property(self, "modulate:a", 0.0, 1.0)
	
	await mod_tween.finished


func enable_difficulties(id: String) -> void:
	# Check beatmap paths. Disable difficulties with no beatmap
	var easy_beatmap: String = CustomMusicManager.library[id][CustomMusicManager.Library_Keys.EASY_CHART_PATH]
	var med_beatmap: String = CustomMusicManager.library[id][CustomMusicManager.Library_Keys.MEDIUM_CHART_PATH]
	var hard_beatmap: String = CustomMusicManager.library[id][CustomMusicManager.Library_Keys.HARD_CHART_PATH]
	
	if easy_beatmap.is_empty():
		easy_btn.disabled = true
	else:
		easy_btn.disabled = false
	
	if med_beatmap.is_empty():
		medium_btn.disabled = true
	else:
		medium_btn.disabled = false
	
	if hard_beatmap.is_empty():
		hard_btn.disabled = true
	else:
		hard_btn.disabled = false


func set_info(_name: String, _artist: String, _score: int, _art: Texture2D) -> void:
	song_title.set_text(_name)
	song_artist.set_text(_artist)
	album_art.set_texture(_art)
	set_score(_score)


func set_score(_score: int) -> void:
	var result: String = Utils.set_score(_score)
	
	score.set_text(result)
