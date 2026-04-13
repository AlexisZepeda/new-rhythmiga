class_name FinishLabel
extends PanelContainer

@export var finish_texture: TextureRect


func _ready() -> void:
	pivot_offset_ratio = Vector2(0.5, 0.5)


func start_anim() -> void:
	#var mod_tween: Tween = create_tween()
	#var font_tween: Tween = create_tween()
	
	#mod_tween.tween_property(self, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	#font_tween.tween_property(label, "theme_override_font_sizes/font_size", 60, 0.5).set_trans(Tween.TRANS_SINE)
	
	if finish_texture.material is ShaderMaterial:
		var alpha_tween: Tween = create_tween()
		
		finish_texture.material.set_shader_parameter("invert", true)
		
		alpha_tween.tween_property(finish_texture.material, "shader_parameter/progress", 2.0, 1.0)
		
		await alpha_tween.finished
		
		await get_tree().create_timer(1.0).timeout
		
		await disappear_anim()


func disappear_anim() -> void:
	if finish_texture.material is ShaderMaterial:
		var alpha_tween: Tween = create_tween()
		
		#start_texture.material.set_shader_parameter("invert", false)
		
		alpha_tween.tween_property(finish_texture.material, "shader_parameter/progress", 0.0, 1.0)
		
		await alpha_tween.finished
