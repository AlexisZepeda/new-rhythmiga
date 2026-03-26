class_name TimingLabelPrefab
extends Label


func _ready() -> void:
	add_text("Void")


func _clear_text() -> void:
	text = ""
	queue_free()


func add_text(string: String) -> void:
	set_text(string)
	
	position.x = randf_range(position.x - 10.0, position.x + 60.0)
	position.y = randf_range(position.y - 10.0, position.y + 50.0)
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", position.y - 10, 0.5).set_trans(Tween.TRANS_QUAD)
	
	await tween.finished
	
	_clear_text()
