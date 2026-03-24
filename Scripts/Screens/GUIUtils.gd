class_name GUIUtils


static func update_container(panel: Panel, arc: AspectRatioContainer, gui_aspect_ratio: float, gui_margin: float) -> void:
	# The code within this function needs to be run deferred to work around an issue with containers
	# having a 1-frame delay with updates.
	# Otherwise, `panel.size` returns a value of the previous frame, which results in incorrect
	# sizing of the inner AspectRatioContainer when using the Fit to Window setting.
	for _i in 2:
		if is_equal_approx(gui_aspect_ratio, -1.0):
			# Fit to Window. Tell the AspectRatioContainer to use the same aspect ratio as the window,
			# making the AspectRatioContainer not have any visible effect.
			arc.ratio = panel.size.aspect()
			# Apply GUI offset on the AspectRatioContainer's parent (Panel).
			# This also makes the GUI offset apply on controls located outside the AspectRatioContainer
			# (such as the inner side label in this demo).
			panel.offset_top = gui_margin
			panel.offset_bottom = -gui_margin
		else:
			# Constrained aspect ratio.
			arc.ratio = min(panel.size.aspect(), gui_aspect_ratio)
			# Adjust top and bottom offsets relative to the aspect ratio when it's constrained.
			# This ensures that GUI offset settings behave exactly as if the window had the
			# original aspect ratio size.
			panel.offset_top = gui_margin / gui_aspect_ratio
			panel.offset_bottom = -gui_margin / gui_aspect_ratio
	
		panel.offset_left = gui_margin
		panel.offset_right = -gui_margin


static func get_all_buttons(node: Node) -> Array:
	var buttons: Array = []
	
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
			child.modulate.a = 0.0
		if child.get_child_count() > 0:
			buttons += get_all_buttons(child)
	
	return buttons


static func buttons_array_sorting(a: Button, b: Button) -> bool:
	if a.global_position.y == b.global_position.y:
		return a.global_position.x < b.global_position.x
	
	return a.global_position.y < b.global_position.y
