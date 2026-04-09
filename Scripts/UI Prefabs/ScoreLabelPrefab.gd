class_name ScoreLabel
extends Label


func set_score(new_score: String) -> void:
	var score_tween: Tween = create_tween()
	
	score_tween.tween_property(self, "text", new_score, 0.1)
	
	await score_tween.finished
