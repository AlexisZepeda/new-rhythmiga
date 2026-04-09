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

var difficulty: Enums.Difficulty


func _ready() -> void:
	easy_btn.pressed.connect(_on_easy_pressed)
	medium_btn.pressed.connect(_on_medium_pressed)
	hard_btn.pressed.connect(_on_hard_pressed)
	
	_set_difficulty_pressed()


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


func set_info(_name: String, _artist: String, _score: String, _art: Texture2D) -> void:
	song_title.set_text(_name)
	song_artist.set_text(_artist)
	album_art.set_texture(_art)
	score.set_text(_score)


func set_score(_score: String) -> void:
	score.set_text(_score)
