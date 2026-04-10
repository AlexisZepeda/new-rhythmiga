class_name StartLabel
extends PanelContainer

@export var label: Label


func _ready() -> void:
	pivot_offset_ratio = Vector2(0.5, 0.5)
	modulate.a = 0.0
	
	appear_anim()


func appear_anim() -> void:
	var mod_tween: Tween = create_tween()
	var font_tween: Tween = create_tween()
	
	mod_tween.tween_property(self, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	font_tween.tween_property(label, "theme_override_font_sizes/font_size", 60, 0.5).set_trans(Tween.TRANS_SINE)
	
	if material is ShaderMaterial:
		var alpha_tween: Tween = create_tween()
		
		alpha_tween.tween_property(material, "shader_parameter/progress", 4.0, 1.0)
