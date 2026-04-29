class_name FileReader

enum Beatmap_Keys {
	INIT_OFFSET,
	INIT_BPM,
	NOTES,
}

## Header for info.dat file
const INFO_HEADER: int = 0x494E464F 
## Header for beatmap.dat file
const BEATMAP_HEADER: int = 0x42454154


func beatmap_create(file_path: String, notes: Array, events: Dictionary, init_offset: float, init_bpm: float) -> void:
	#if FileAccess.file_exists(file_path):
	print("Open Beatmap file %s" % file_path)
	
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	
	if FileAccess.get_open_error() != OK:
		print("Unable to open file %s" % file)
		
		return
	
	var beatmap_file_reader: BeatMapFileReader = BeatMapFileReader.new()
	beatmap_file_reader.create(file, notes, events, init_offset, init_bpm)


func beatmap_open(file_path: String) -> Dictionary:
	if FileAccess.file_exists(file_path):
		
		var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
		
		if FileAccess.get_open_error() != OK:
			print("Unable to open file %s" % file)
			
			return {}
		
		var header: int = file.get_32()
		
		if header == BEATMAP_HEADER:
			var beatmap_file_reader: BeatMapFileReader = BeatMapFileReader.new()
			return beatmap_file_reader.parse(file)
		else:
			return {}
	else:
		return {}


func info_create(file_path: String, info: Dictionary) -> void:
	#if FileAccess.file_exists(file_path):
	print("Open Info file")
	
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	
	if FileAccess.get_open_error() != OK:
		print("Unable to open file %s" % file)
		
		return
	
	var info_file_reader: InfoFileReader = InfoFileReader.new()
	info_file_reader.create(file, info)



## Opens and parses file based on HEADER
func info_open(file_path: String) -> Dictionary:
	if FileAccess.file_exists(file_path):
		
		var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
		
		if FileAccess.get_open_error() != OK:
			print("Unable to open file %s" % file)
			
			return {}
		
		var header: int = file.get_32()
		
		if header == INFO_HEADER:
			var info_file_reader: InfoFileReader = InfoFileReader.new()
			return info_file_reader.parse(file)
		else:
			return {}
	else:
		return {}


class InfoFileReader:
	func create(file: FileAccess, info: Dictionary) -> void:
		file.store_32(INFO_HEADER)
		file.store_var(info)
		file.close()
	
	
	func parse(file: FileAccess) -> Dictionary:
		var dictionary: Dictionary = file.get_var()
		
		return dictionary


class BeatMapFileReader:
	## Subheader for info in beatmap.dat file
	const BEATMAP_INFO_HEADER: int = 0x4245464F
	## Subheader for notes in beatmap.dat file
	const BEATMAP_NOTE_HEADER: int = 0x4E4F5445
	## Subheader for BPM events in beatmap.dat file
	const BEATMAP_BPM_EVENT_HEADER: int = 0x42504D45
	## Subheader for Scroll events in beatmap.dat file
	const BEATMAP_SCROLL_EVENT_HEADER: int = 0x7363726C
	
	func create(file: FileAccess, notes: Array, _events: Dictionary, init_offset: float, init_bpm: float) -> void:
		file.store_32(BEATMAP_HEADER)
		file.store_32(BEATMAP_INFO_HEADER)
		file.store_float(init_offset)
		file.store_float(init_bpm)
		file.store_32(BEATMAP_BPM_EVENT_HEADER)
		file.store_32(BEATMAP_SCROLL_EVENT_HEADER)
		
		file.store_32(BEATMAP_NOTE_HEADER)
		
		for note: ChartNote in notes:
			var format: String =  "%s:%s%s%s%s" % [note._ticks, note.type, note.lane, note.direction, note.direction_2]
			file.store_pascal_string(format)
		
		file.close()
	
	
	func parse(file: FileAccess) -> Dictionary:
		var dictionary: Dictionary = {
			Beatmap_Keys.NOTES: {
				
			}
		}
		
		var temp: Dictionary = {}
		var regex: RegEx = RegEx.new()
		regex.compile("^[^:]+")
		
		if file.get_32() == BEATMAP_INFO_HEADER:
			var offset: float = file.get_float()
			var init_bpm: float = file.get_float()
			
			dictionary[Beatmap_Keys.INIT_OFFSET] = offset
			dictionary[Beatmap_Keys.INIT_BPM] = init_bpm
		if file.get_32() == BEATMAP_BPM_EVENT_HEADER:
			pass
		if file.get_32() == BEATMAP_SCROLL_EVENT_HEADER:
			pass
		if file.get_32() == BEATMAP_NOTE_HEADER:
			while not file.eof_reached():
				var line: String = file.get_pascal_string()
				
				if line.is_empty():
					continue
				
				var regex_match: RegExMatch = regex.search(line)
				var result: String = regex_match.get_string()
				
				if result:
					var tick: float = float(result)
					var separator: int = line.find(":")
					
					var content: String = line.substr(separator + 1)
					
					var note_type: int = int(content[0])
					var note_lane: int = int(content[1])
					var direction: int = int(content[2])
					var direction_2: int = int(content[3])
					
					#temp[tick] = [note_lane, note_type, direction, direction_2]
					
					
					if temp.has(tick):
						temp[tick].append([note_lane, note_type, direction, direction_2])
					else:
						temp[tick] = []
						temp[tick].append([note_lane, note_type, direction, direction_2])
			
			dictionary[Beatmap_Keys.NOTES].merge(temp)
		
		file.close()
		
		return dictionary
