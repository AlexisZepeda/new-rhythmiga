extends SubViewportContainer

const DEFAULT_WAVE_SPEED: float = 0.6
const DEFAULT_GWM: float = 1.5
const DEFAULT_TM: float = 0.25
const LOADING_WAVE_SPEED: float = 2.5

@export var background: ColorRect


## Used in [Loader]
func change_wave_speed(is_loading: bool=true) -> void:
	var _material: ShaderMaterial = null
	
	if background.material is ShaderMaterial:
		_material = background.material
		
		if is_loading:
			var wave_tween: Tween = create_tween()
			wave_tween.tween_property(_material, "shader_parameter/wave_speed", LOADING_WAVE_SPEED, 2.0)
			await wave_tween.finished
			
			#_material.set_shader_parameter("wave_speed", LOADING_WAVE_SPEED)
		else:
			#wave_tween.tween_property(_material, "shader_parameter/wave_speed", DEFAULT_WAVE_SPEED, 2.0)
			#wave_tween.chain().tween_property(_material, "shader_parameter/wave_speed", DEFAULT_WAVE_SPEED, 1.0)
			_material.set_shader_parameter("wave_speed", DEFAULT_WAVE_SPEED)


func disappear_shader() -> void:
	var _material: ShaderMaterial = null
	
	if background.material is ShaderMaterial:
		_material = background.material
		
		var wave_tween: Tween = create_tween()
		
		wave_tween.tween_property(_material, "shader_parameter/wave_speed", 0.0, 0.5)
		wave_tween.tween_property(_material, "shader_parameter/GWM", 0.0, 0.5)
		wave_tween.tween_property(_material, "shader_parameter/TM", 0.0, 0.5)


func appear_shader() -> void:
	var _material: ShaderMaterial = null
	
	if background.material is ShaderMaterial:
		_material = background.material
		
		var wave_tween: Tween = create_tween()
		wave_tween.tween_property(_material, "shader_parameter/wave_speed", DEFAULT_WAVE_SPEED, 1.0)
		wave_tween.tween_property(_material, "shader_parameter/GWM", DEFAULT_GWM, 1.0)
		wave_tween.tween_property(_material, "shader_parameter/TM", DEFAULT_TM, 1.0)
