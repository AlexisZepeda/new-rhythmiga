class_name Countdown
extends PanelContainer

signal finished

const COUNTDOWN_WAIT_TIME: float = 3.0

@export var countdown_label: Label
@export var timer: Timer

var current_time: int = int(COUNTDOWN_WAIT_TIME)


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	start()


func _process(_delta: float) -> void:
	countdown_label.set_text(str(ceili(timer.time_left)))


func start() -> void:
	timer.wait_time = COUNTDOWN_WAIT_TIME
	timer.start()


func _on_timer_timeout() -> void:
	finished.emit()
