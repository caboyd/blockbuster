extends ColorRect

# If the grid is not a child of this node, update this path 
# to point to your Block_Grid node


func _ready() -> void:
	# 1. Connect to the viewport signal
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	# 2. Set initial size and position
	_on_viewport_resized()

func _on_viewport_resized() -> void:
	var screen_size = get_viewport_rect().size
	
	# Resize this ColorRect to fill the screen
	size = screen_size / scale
	
	# Ensure the background stays at the top-left of the CanvasLayer
	global_position = Vector2.ZERO
	

	# If your shader needs the size to prevent squishing, update it here:
	if material is ShaderMaterial:
		material.set_shader_parameter("resolution", size)
		material.set_shader_parameter("cell_size", size.y / 20)
