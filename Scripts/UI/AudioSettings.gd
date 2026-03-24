extends VBoxContainer

@export_category("Volume Sliders")
@export var master_slider: VolumeSlider
@export var music_slider: VolumeSlider
@export var sfx_slider: VolumeSlider
@export_category("")

@export var apply_button: Button
@export var reset_button: Button

func _ready() -> void:
	apply_button.pressed.connect(_on_apply_pressed)
	reset_button.pressed.connect(_on_reset_pressed)


func _on_apply_pressed() -> void:
	UserConfig.set_audio_pref(master_slider.value, music_slider.value, sfx_slider.value)
	UserConfig.apply_user_pref_section(UserConfig.AUDIO_SECTION)


func _on_reset_pressed() -> void:
	master_slider.reset()
	music_slider.reset()
	sfx_slider.reset()
