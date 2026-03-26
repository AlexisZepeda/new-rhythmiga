class_name LongNoteLine
extends Line2D


func hit_perfect() -> void:
	modulate = Color.YELLOW
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.2)
	tween.parallel().tween_property(self, ^"scale", 1.5 * Vector2.ONE, 0.2)
	
	hide()
	
	tween.tween_callback(queue_free)


func hit_critical() -> void:
	modulate = Color.ORANGE_RED
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.2)
	tween.parallel().tween_property(self, ^"scale", 1.5 * Vector2.ONE, 0.2)
	tween.tween_callback(queue_free)


func hit_great() -> void:
	modulate = Color.FOREST_GREEN
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.2)
	tween.parallel().tween_property(self, ^"scale", 1.2 * Vector2.ONE, 0.2)
	
	hide()
	
	tween.tween_callback(queue_free)


func hit_good() -> void:
	modulate = Color.DEEP_SKY_BLUE
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.2)
	tween.parallel().tween_property(self, ^"scale", 1.2 * Vector2.ONE, 0.2)
	
	hide()
	
	tween.tween_callback(queue_free)


func hit_bad() -> void:
	modulate = Color.PURPLE

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.2)
	tween.parallel().tween_property(self, ^"scale", 1.2 * Vector2.ONE, 0.2)
	tween.tween_callback(queue_free)


func miss() -> void:
	modulate = Color.DARK_RED
	
	var tween := create_tween()
	tween.parallel().tween_property(self, ^"modulate:a", 0, 0.5)
	tween.tween_callback(queue_free)
