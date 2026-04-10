class_name SongPanel
extends MarginContainer

@export_category("Song Info")
@export var song_title: Label
@export var artist: Label
@export var cover_art: TextureRect
@export var difficulty: Label


var song_title_str: String = "Title": set=set_song_title
var artist_str: String = "Artist": set=set_artist
var cover_art_texture: String = "": set=set_cover_art
var difficulty_str: String = "Difficulty": set=set_difficulty


func set_info() -> void:
	song_title_str = CustomMusicManager.load_song_name()
	artist_str = CustomMusicManager.load_artist_name()
	cover_art_texture = CustomMusicManager.load_cover_art()
	difficulty_str = Utils.get_difficulty(CustomMusicManager.current_difficulty)


func set_song_title(value: String) -> void:
	song_title_str = value
	song_title.set_text(value)


func set_artist(value: String) -> void:
	artist_str = value
	artist.set_text(value)


func set_cover_art(value: String) -> void:
	cover_art_texture = value
	
	if value == "" :
		return
	
	var texture: ImageTexture = ImageTexture.new()
	var image: Image = Image.load_from_file(value)
	texture.set_image(image)
	
	cover_art.set_texture(texture)


func set_difficulty(value: String) -> void:
	difficulty_str = value
	difficulty.set_text(value)
