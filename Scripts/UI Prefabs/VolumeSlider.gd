class_name VolumeSlider
extends HSlider

@export var audio_bus_name: String = "Master"

var default_level: float = 1.0

@onready var _bus = AudioServer.get_bus_index(audio_bus_name)


func _ready() -> void:
	value = db_to_linear(AudioServer.get_bus_volume_db(_bus))


func _on_value_changed(_value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(_value))


func _on_mouse_exited() -> void:
	release_focus()


func reset() -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(default_level))
	value = db_to_linear(AudioServer.get_bus_volume_db(_bus))
