class_name UserData

static var path: String = "user://userdata.dat"
static var save_data: Dictionary[String, Dictionary] = {}


static func get_score(id: String, difficulty: Enums.Difficulty) -> int:
	if save_data.has(id):
		if save_data[id].has(difficulty):
			return save_data[id][difficulty]
	
	return 0


static func load_data() -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	if FileAccess.get_open_error() == OK:
		save_data = file.get_var(true)
		print(save_data)
		print("Loaded")


static func save_score(score: int, difficulty: Enums.Difficulty) -> void:
	var key: String = CustomMusicManager.current_id
	
	if save_data.has(key):
		save_data[key][difficulty] = score
	else:
		save_data[key] = {
			difficulty: score
		}
	
	save()
	print(save_data)


static func save() -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	
	if FileAccess.get_open_error() == OK:
		file.store_var(save_data)
		print("Saved")
	
	file.close()
