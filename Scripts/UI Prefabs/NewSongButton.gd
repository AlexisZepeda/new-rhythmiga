class_name NewSongButton
extends MarginContainer

@export var panel: Panel
@export var animation_player: AnimationPlayer
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
var cover_art_texture: String = "": set=set_cover_art
var score_str: int = 0: set=set_score
var difficulty_str: String = "Difficulty": set=set_difficulty

var audio_stream: AudioStream = null

var id: String = "": set=_set_id


func _ready() -> void:
	self.scale.x = 0.0
	
	panel.mouse_entered.connect(_on_panel_mouse_entered)
	panel.mouse_exited.connect(_on_panel_mouse_exited)
	
	await appear_anim()


func _on_panel_mouse_entered() -> void:
	var stylebox: StyleBox = panel.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color(0.39, 0.39, 0.39, 0.6)
	panel.add_theme_stylebox_override("panel", stylebox)


func _on_panel_mouse_exited() -> void:
	var stylebox: StyleBox = panel.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color(0.39, 0.39, 0.39, 0.0)
	panel.add_theme_stylebox_override("panel", stylebox)


func _set_id(value: String) -> void:
	id = value


func appear_anim() -> void:
	#var scale_tween: Tween = create_tween()
	
	#scale_tween.tween_property(self, "scale:x", 1.0, 1.0)
	
	animation_player.play("appear")
	
	#await scale_tween.finished
	await animation_player.animation_finished


func disappear_anim() -> void:
	animation_player.play("disappear")
	await animation_player.animation_finished


func set_song_title(value: String) -> void:
	song_title_str = value
	song_title.set_text(value)


func set_artist(value: String) -> void:
	artist_str = value
	artist.set_text(value)


func set_album(value: String) -> void:
	album_str = value
	album.set_text(value)


func set_cover_art(value: String) -> void:
	cover_art_texture = value
	
	if value == "" :
		return
	
	var texture: ImageTexture = ImageTexture.new()
	var image: Image = Image.load_from_file(value)
	texture.set_image(image)
	
	cover_art.set_texture(texture)


func set_score(value: int) -> void:
	score_str = value
	
	var string: String = Utils.set_score(score_str)
	
	score.set_text(string)


func set_difficulty(value: String) -> void:
	difficulty_str = value
	difficulty.set_text(value)
