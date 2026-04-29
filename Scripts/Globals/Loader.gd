extends Node

signal LOADING_PROGRESS_UPDATED(percentage)
signal LOADED_SCENE(node: Node)

@export var loadingScene = preload("res://Scenes/Screens/Background Screens/loading_screen.tscn").instantiate()

var scene_path: String = ""
var parent: Node

var loaded_stream: AudioStream = null
var beat_map_path: String = ""
var loaded_music_path: String = ""


#func _ready() -> void:
	#get_tree().node_added.connect(_on_node_added)
#
#
#func _on_node_added(node: Node) -> void:
	#print("Added node %s" % node)
	#if node == get_tree().current_scene:
		#print("Scene changed to: ", node.name)


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
			
			if parent != get_tree().root:
				get_tree().current_scene = parent
			
			get_tree().root.remove_child(loadingScene)
			parent.add_child(loadedScene)
			
			if loadedScene is MainUIScreen:
				scene_path = ""
			
			LOADED_SCENE.emit(loadedScene)
