extends Control


@export_file("*tscn") var title_screen_path: String
@export var splash_img: TextureRect


func _init() -> void:
	UserData.load_data()



func _ready() -> void:
	var mod_tween: Tween = get_tree().create_tween()
	
	mod_tween.tween_property(splash_img, "modulate:a", 1.0, 2.0)
	
	mod_tween.tween_interval(0.5)
	
	mod_tween.tween_property(splash_img, "modulate:a", 0.0, 1.0)
	
	await mod_tween.finished
	
	Loader.load_scene(self, title_screen_path, get_tree().root)
