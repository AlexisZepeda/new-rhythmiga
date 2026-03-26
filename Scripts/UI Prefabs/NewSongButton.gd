class_name NewSongButton
extends MarginContainer

@export var button: Button
@export_category("Song Info")
@export var song_title: Label
@export var artist: Label
@export var album: Label
@export var cover_art: TextureRect
@export var score: Label
@export var difficulty: Label

var song_title_str: String = "Title": set=set_song_title
var artist_str: String = "Artist": set=set_artist
var album_str: String = "Album": set=set_album
var cover_art_texture: Texture2D = null: set=set_cover_art
var score_str: String = "Score": set=set_score
var difficulty_str: String = "Difficulty": set=set_difficulty

var audio_stream: AudioStream = null


var id: String = "": set=_set_id


func _set_id(value: String) -> void:
	id = value


func set_song_title(value: String) -> void:
	song_title_str = value
	song_title.set_text(value)


func set_artist(value: String) -> void:
	artist_str = value
	artist.set_text(value)


func set_album(value: String) -> void:
	album_str = value
	album.set_text(value)


func set_cover_art(value: Texture2D) -> void:
	cover_art_texture = value
	cover_art.set_texture(value)


func set_score(value: String) -> void:
	score_str = value
	score.set_text(value)


func set_difficulty(value: String) -> void:
	difficulty_str = value
	difficulty.set_text(value)
