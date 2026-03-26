class_name Utils

const WAV_EXTENSION: String = "wav"
const OGG_EXTENSION: String = "ogg"


static func create_audio_stream(path: String) -> AudioStream:
	print("Create Audio Stream Audio Path %s" % path)
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
