class_name SavedLabel
extends Label

signal finished


func _ready() -> void:
	self.modulate = Color(255, 255, 255, 0)
	play_animation()


func play_animation() -> void:
	var tween: Tween = get_tree().create_tween()
	
	tween.tween_property(self, "modulate:a", 1, 1.0)
	tween.chain().tween_property(self, "modulate:a", 0, 0.25)
	
	await tween.finished
	
	finished.emit()
	
	queue_free()
