class_name AudioClipPlayer
extends AudioStreamPlayer

@export var timer: Timer

var song_preview_start: float = 0.0
var song_preview_end: float = 0.0
var loop_duration: float = 0.0


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)


func _restart() -> void:
	var vol_tween: Tween = create_tween()
	vol_tween.tween_property(self, "volume_linear", 1.0, 2.0)
	
	play(song_preview_start)
	timer.start()
	
	print("resart")


func _on_timer_timeout() -> void:
	var vol_tween: Tween = create_tween()
	vol_tween.tween_property(self, "volume_linear", 0.0, 1.0)
	
	await vol_tween.finished
	
	vol_tween.stop()
	#volume_db = 0.0
	
	_restart()


func lower_volume(time: float) -> void:
	var vol_tween: Tween = create_tween()
	vol_tween.tween_property(self, "volume_linear", 0.0, time)
	
	await vol_tween.finished


func start(_preview_start: float, _preview_end: float) -> void:
	song_preview_start = _preview_start
	song_preview_end = _preview_end
	
	loop_duration = abs(song_preview_end - song_preview_start)
	timer.wait_time = loop_duration
	play(song_preview_start)
	timer.start()
	
