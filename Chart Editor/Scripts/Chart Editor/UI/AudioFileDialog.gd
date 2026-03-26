extends FileDialog

@export var file_path: String = ""
@export var file: String = "" : set = set_file_name
@export var file_extension: String = ""
@export var file_name: String = ""


func _on_file_selected(path: String) -> void:
	print(path)
	file_path = path
	file = path.get_file()
	print(file)


func set_file_name(value: String) -> void:
	file = value
	file_extension = file.get_extension()
	file_name = file.get_basename()
