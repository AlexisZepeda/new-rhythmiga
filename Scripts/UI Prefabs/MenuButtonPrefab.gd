class_name MenuButtonPrefab
extends Button

const POSITION_X_TWEEN_MOVEMENT: int = 20

var original_position: Vector2 = position
var original_scale: Vector2 = scale

var tween_pos: Tween
var tween_scale: Tween
var tween_mod: Tween

var disable_anim: bool = false


func _ready() -> void:
	disable_anim = false
	
	pressed.connect(_on_pressed)
	
	mouse_entered.connect(_on_entered)
	mouse_exited.connect(_on_exited)
	
	focus_entered.connect(_on_entered)
	focus_exited.connect(_on_exited)


func _on_pressed() -> void:
	disable_anim = true


func _on_entered() -> void:
	if tween_pos:
		tween_pos.kill()
	
	tween_pos = create_tween().set_parallel()
	
	if tween_scale:
		tween_scale.kill()
	
	tween_scale = create_tween().set_parallel()
	#var tween_pos: Tween = create_tween().set_parallel()
	#var tween_scale: Tween = create_tween().set_parallel()
	
	tween_pos.tween_property(self, "position:x", position.x + POSITION_X_TWEEN_MOVEMENT, 0.25)
	tween_scale.tween_property(self, "theme_override_font_sizes/font_size", 40, 0.1)

	#tween_scale.tween_property(self, "scale", scale + Vector2(0.5, 0.5), 0.25)
	#add_theme_font_size_override("font_size", 40)


func _on_exited() -> void:
	if disable_anim:
		return
	
	if tween_pos:
		tween_pos.kill()
	
	tween_pos = create_tween().set_parallel()
	
	if tween_scale:
		tween_scale.kill()
	
	tween_scale = create_tween().set_parallel()
	#var tween_pos: Tween = create_tween().set_parallel()
	#var tween_scale: Tween = create_tween().set_parallel()
	
	tween_pos.tween_property(self, "position:x", original_position.x, 0.2)
	tween_scale.tween_property(self, "theme_override_font_sizes/font_size", 28, 0.1)
	#tween_scale.tween_property(self, "scale", original_scale, 0.25)
	#add_theme_font_size_override("font_size", 28)
