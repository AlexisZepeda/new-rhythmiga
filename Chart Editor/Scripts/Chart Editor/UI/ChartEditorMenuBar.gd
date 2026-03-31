class_name FileMenuBar
extends MenuBar

signal import_audio_file_pressed
signal save_pressed
signal save_as_pressed
signal load_pressed
signal export_pressed
signal quit_pressed

@export var file_popup_menu: PopupMenu

enum File_Menu {
	OPEN_AUDIO,
	NEW,
	SAVE,
	SAVE_AS,
	LOAD_FILE,
	EXPORT_CHART,
	QUIT,
}

var file_popup_children: Dictionary = {
	File_Menu.OPEN_AUDIO: "Open Audio File",
	File_Menu.NEW: "New",
	File_Menu.SAVE: "Save",
	File_Menu.SAVE_AS: "Save As",
	File_Menu.LOAD_FILE: "Load File",
	File_Menu.EXPORT_CHART: "Export",
	File_Menu.QUIT: "Quit",
}


func _ready() -> void:
	_create_file_menu_popup_items()
	file_popup_menu.id_pressed.connect(_on_file_popup_id_pressed)


func _on_file_popup_id_pressed(id: int) -> void:
	match id:
		File_Menu.OPEN_AUDIO:
			import_audio_file_pressed.emit()
		File_Menu.NEW:
			pass
		File_Menu.SAVE:
			save_pressed.emit()
		File_Menu.SAVE_AS:
			save_as_pressed.emit()
		File_Menu.LOAD_FILE:
			load_pressed.emit()
		File_Menu.EXPORT_CHART:
			export_pressed.emit()
		File_Menu.QUIT:
			quit_pressed.emit()


func _create_file_menu_popup_items() -> void:
	for item in file_popup_children:
		var label: String = file_popup_children[item]
		file_popup_menu.add_item(label, item)
