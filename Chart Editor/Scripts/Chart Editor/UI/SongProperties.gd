class_name SongProperties
extends MarginContainer

@export_group("Edits")
@export var title_edit: LineEdit
@export var artist_edit: LineEdit
@export var credit_edit: LineEdit
@export var start_preview_edit: LineEdit
@export var end_preview_edit: LineEdit
@export_group("")

@export_group("Buttons")
@export var set_preview_btn: Button
@export var cover_btn: Button
@export var difficulty_btn: OptionButton
@export_group("")

@export var cover_file_dialog: FileDialog
@export var cover_path: Label
@export var cover_art: TextureRect

var difficulty: String

var song_preview_start: float = 0.0
var song_preview_end: float = 0.0

var cover_art_path: String = ""


func _ready() -> void:
	cover_btn.pressed.connect(_cover_btn_pressed)
	set_preview_btn.pressed.connect(_set_preview_pressed)
	cover_file_dialog.file_selected.connect(_cover_file_dialog_file_selected)
	difficulty_btn.item_selected.connect(_difficulty_btn_pressed)
	
	cover_file_dialog.set_filename_filter("cover.*")
	
	for key in Enums.Difficulty:
		difficulty_btn.add_item(key)
	
	difficulty_btn.select(0)
	difficulty = Enums.Difficulty.keys()[0]


func _cover_btn_pressed() -> void:
	cover_file_dialog.show()


func _set_preview_pressed() -> void:
	var start: String = start_preview_edit.get_text()
	var end: String = end_preview_edit.get_text()
	
	if start.is_valid_float():
		song_preview_start = float(start)
	
	if end.is_valid_float():
		song_preview_end = float(end)


func _cover_file_dialog_file_selected(path: String) -> void:
	cover_art_path = path
	
	cover_path.set_text(path.get_file())
	
	var texture: ImageTexture = ImageTexture.new()
	var image: Image = Image.load_from_file(path)
	texture.set_image(image)
	
	cover_art.set_texture(texture)


func _difficulty_btn_pressed(index: int) -> void:
	difficulty = Enums.Difficulty.keys()[index]


func export_information() -> Dictionary:
	var dictionary: Dictionary = {
		CustomMusicManager.Library_Keys.SONG_NAME: title_edit.text,
		CustomMusicManager.Library_Keys.ARTIST: artist_edit.text,
		CustomMusicManager.Library_Keys.CREDIT: credit_edit.text,
		CustomMusicManager.Library_Keys.COVER_PATH: cover_art_path,
		CustomMusicManager.Library_Keys.DIFFICULTY: difficulty,
		CustomMusicManager.Library_Keys.SONG_PREVIEW_START: song_preview_start,
		CustomMusicManager.Library_Keys.SONG_PREVIEW_END: song_preview_end,
	}
	
	return dictionary


func set_information(dict: Dictionary) -> void:
	title_edit.text = dict[CustomMusicManager.Library_Keys.SONG_NAME]
	artist_edit.text = dict[CustomMusicManager.Library_Keys.ARTIST]
	credit_edit.text = dict[CustomMusicManager.Library_Keys.CREDIT]
	cover_art_path = dict[CustomMusicManager.Library_Keys.COVER_PATH]
	difficulty = dict[CustomMusicManager.Library_Keys.DIFFICULTY]
	song_preview_start = dict[CustomMusicManager.Library_Keys.SONG_PREVIEW_START]
	song_preview_end = dict[CustomMusicManager.Library_Keys.SONG_PREVIEW_END]
	
	_cover_file_dialog_file_selected(cover_art_path)
	start_preview_edit.text = str(song_preview_start)
	end_preview_edit.text = str(song_preview_end)
	set_difficuty(difficulty)


func set_difficuty(string: String) -> void:
	print(string)
