class_name Utils

const WAV_EXTENSION: String = "wav"
const OGG_EXTENSION: String = "ogg"

static var up_right_vector: Vector2 = Vector2( 1, -1).normalized()
static var down_right_vector: Vector2 = Vector2( 1,  1).normalized()
static var up_left_vector: Vector2 = Vector2( -1,  -1).normalized()
static var down_left_vector: Vector2 = Vector2( -1,  1).normalized()


static func create_audio_stream(path: String) -> AudioStream:
	#print("Create Audio Stream Audio Path %s" % path)
	var extension: String = path.get_extension()
	var audio_stream: AudioStream = null
	
	match extension:
		OGG_EXTENSION:
			audio_stream = Utils.load_ogg_vorbis_stream(path)
		WAV_EXTENSION:
			audio_stream = Utils.load_wav_stream(path)
	
	return audio_stream


static func load_ogg_vorbis_stream(path: String) -> AudioStreamOggVorbis:
	return AudioStreamOggVorbis.load_from_file(path)


static func load_wav_stream(path: String) -> AudioStreamWAV:
	return AudioStreamWAV.load_from_file(path)


static func get_file_name(path: String, suffix: String) -> String:
	return path.get_file().trim_suffix(suffix)


static func set_score(score_int: int) -> String:
	var result: String = ""
	
	if score_int == 0:
		result = "-"
	else:
		result = str(score_int)
	
	return result


static func get_difficulty(difficulty: Enums.Difficulty) -> String:
	return (Enums.Difficulty.keys()[difficulty]).to_pascal_case()


static func get_beat(ticks: int) -> float:
	return float(ticks) / GlobalSettings.PPQ


static func get_direction(vector: Vector2) -> Enums.Direction:
	var direction: Enums.Direction = Enums.Direction.UP
	
	match vector:
		Vector2.UP:
			direction = Enums.Direction.UP
		Vector2.DOWN:
			direction = Enums.Direction.DOWN
		Vector2.LEFT:
			direction = Enums.Direction.LEFT
		Vector2.RIGHT:
			direction = Enums.Direction.RIGHT
		up_right_vector:
			direction = Enums.Direction.UP_RIGHT
		down_right_vector:
			direction = Enums.Direction.DOWN_RIGHT
		up_left_vector:
			direction = Enums.Direction.UP_LEFT
		down_left_vector:
			direction = Enums.Direction.DOWN_LEFT
	
	return direction
