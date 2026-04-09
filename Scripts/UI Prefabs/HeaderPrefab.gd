class_name HeaderPrefab
extends VBoxContainer

@export_category("Parameters")
@export var title: String: set=set_label_text
@export var horizontal_align: HorizontalAlignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT: set=_set_horizontal_align
@export var vertical_align: VerticalAlignment = VerticalAlignment.VERTICAL_ALIGNMENT_TOP: set=_set_vertical_align
@export_category("")
@export_category("Children")
@export var label: Label
@export var animation_player: AnimationPlayer
@export_category("")


func _ready() -> void:
	pivot_offset_ratio = Vector2(0.5, 0.5)


func set_label_text(value: String) -> void:
	var to_lower: String = value.to_lower()
	
	label.set_text(to_lower)


func _set_horizontal_align(value: HorizontalAlignment) -> void:
	label.horizontal_alignment = value


func _set_vertical_align(value: VerticalAlignment) -> void:
	label.vertical_alignment = value


func reset_properties() -> void:
	scale = Vector2.ONE
	modulate.a = 1.0


func appear_anim() -> void:
	animation_player.play("appear")
	await animation_player.animation_finished


func disappear_anim() -> void:
	if visible == true:
		var mod_tween: Tween = create_tween()
		var scale_tween: Tween = create_tween()
		
		scale_tween.tween_property(self, "scale", Vector2(2.0, 2.0), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		mod_tween.tween_property(self, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
		await scale_tween.finished


func enter_anim(position_offset: Vector2) -> void:
	modulate.a = 0.0
	
	var pos_tween: Tween = create_tween()
	var mod_tween: Tween = create_tween()
	var target_pos: Vector2 = position + position_offset
	
	pos_tween.tween_property(self, "position:x", target_pos.x, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	mod_tween.tween_property(self, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await mod_tween.finished


func move_anim(position_offset: Vector2) -> void:
	var pos_tween: Tween = create_tween()
	pos_tween.tween_property(self, "position", position_offset, 1.0).set_trans(Tween.TRANS_LINEAR)
	
	await pos_tween.finished
