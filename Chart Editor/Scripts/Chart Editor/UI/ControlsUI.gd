class_name ControlsUI
extends MarginContainer

@export var file_label: Label
@export var audio_label: Label
@export var bpm_spinbox: SpinBox
@export var offset_line: LineEdit
@export var song_properties: SongProperties


func _ready() -> void:
	GlobalSettings.BPM_CHANGED.connect(_on_bpm_changed)
	GlobalSettings.OFFSET_CHANGED.connect(_on_offset_changed)


func _on_bpm_changed(value: float) -> void:
	bpm_spinbox.value = value


func _on_offset_changed(value: float) -> void:
	offset_line.text = str(value)
	offset_line.text_submitted.emit(str(value))


func _on_enable_metronome_toggled(toggled_on: bool) -> void:
	EmbeddedGlobalSettings.enable_metronome = toggled_on


func _on_enable_auto_toggled(toggled_on: bool) -> void:
	EmbeddedGlobalSettings.enable_auto_input = toggled_on


func set_file_name(file_name: String) -> void:
	file_label.set_text(file_name)


func set_audio_name(audio_name: String) -> void:
	audio_label.set_text(audio_name)


#func enable_save_buttons() -> void:
	#save_button.disabled = false
	#save_as_button.disabled = false


func export() -> Dictionary:
	return song_properties.export_information()


func set_song_properties(dict: Dictionary) -> void:
	song_properties.set_information(dict)
