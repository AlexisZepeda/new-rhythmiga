class_name MusicPlayerPanel
extends MarginContainer

@export_category("Song Info")
@export var song_title: Label
@export var artist: Label
#@export var cover_art: TextureRect
@export_category("Animation")
@export var animation_player: AnimationPlayer


var song_title_str: String = "Title": set=set_song_title
var artist_str: String = "Artist": set=set_artist
#var cover_art_texture: String = "": set=set_cover_art


func _ready() -> void:
	visible = false


func set_info(_song_title: String, _artist: String) -> void:
	song_title_str = _song_title
	artist_str = _artist
	#cover_art_texture = CustomMusicManager.load_cover_art()


func set_song_title(value: String) -> void:
	if value.is_empty():
		song_title_str = "Unknown"
	else:
		song_title_str = value
	song_title.set_text(song_title_str)


func set_artist(value: String) -> void:
	if value.is_empty():
		artist_str = "Unknown"
	else:
		artist_str = value
	artist.set_text(artist_str)


#func set_cover_art(value: String) -> void:
	#cover_art_texture = value
	#
	#if value == "" :
		#return
	#
	#var texture: ImageTexture = ImageTexture.new()
	#var image: Image = Image.load_from_file(value)
	#texture.set_image(image)
	#
	#cover_art.set_texture(texture)

func play_animations() -> void:
	appear_anim()
	
	await get_tree().create_timer(2.0).timeout
	
	disappear_anim()


func appear_anim() -> void:
	visible = true
	
	animation_player.play("appear")
	#await animation_player.animation_finished


func disappear_anim() -> void:
	animation_player.play("disappear")
	await animation_player.animation_finished
	
	visible = false
