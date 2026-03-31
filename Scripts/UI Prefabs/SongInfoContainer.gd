class_name SongInfoContainer
extends MarginContainer


@export var album_art: TextureRect
@export var song_artist: Label
@export var song_title: Label
@export var score: Label


func set_info(_name: String, _artist: String, _score: String, _art: Texture2D) -> void:
	song_title.set_text(_name)
	song_artist.set_text(_artist)
	album_art.set_texture(_art)
