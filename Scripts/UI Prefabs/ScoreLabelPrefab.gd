class_name ScoreLabel
extends Label

var original_position: Vector2 = position


func set_score(new_score: int) -> void:
	var result: String = str(new_score)
	
	var score_tween: Tween = create_tween()
	
	score_tween.tween_property(self, "text", result, 0.1)
	
	await score_tween.finished
