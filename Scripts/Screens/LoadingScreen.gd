extends Control

@export var loadingBar: ProgressBar
@export var header_prefab: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	Loader.LOADING_PROGRESS_UPDATED.connect(_on_progress_updated)


func _on_progress_updated(percentage):
	loadingBar.value = percentage * 100
