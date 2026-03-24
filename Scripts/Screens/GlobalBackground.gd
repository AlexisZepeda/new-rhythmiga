extends SubViewportContainer

const DEFAULT_WAVE_SPEED: float = 0.6
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
		
		
