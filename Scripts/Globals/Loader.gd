extends Node

signal LOADING_PROGRESS_UPDATED(percentage)
signal LOADED_SCENE(node: Node)

@export var loadingScene = preload("res://Scenes/Screens/Background Screens/loading_screen.tscn").instantiate()

var scene_path
var parent: Node

var loaded_stream: AudioStream = null
var beat_map_path: String = ""


func load_scene(caller: Node, path: String, new_parent: Node):
	# AWAIT FOR TESTING LOADING PURPOSE
	#await GlobalBackground.change_wave_speed()
	#GlobalBackground.change_wave_speed()
	
	scene_path = path
	
	get_tree().root.add_child.call_deferred(loadingScene)
	
	ResourceLoader.load_threaded_request(scene_path)
	
	caller.queue_free()
	parent = new_parent


func _process(_delta):
	
	if (scene_path != null):
		var progress = []
		var loaderStatus = ResourceLoader.load_threaded_get_status(scene_path, progress)

		LOADING_PROGRESS_UPDATED.emit(progress[0])

		if (loaderStatus == ResourceLoader.THREAD_LOAD_LOADED):
			#GlobalBackground.change_wave_speed(false)
			var loadedScene = ResourceLoader.load_threaded_get(scene_path).instantiate()
			
			get_tree().root.remove_child(loadingScene)
			parent.add_child(loadedScene)
			
			LOADED_SCENE.emit(loadedScene)
			scene_path = null
