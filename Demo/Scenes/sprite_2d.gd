extends Sprite2D

# Variable renamed to avoid conflict with the built-in Sprite2D.material
@onready var shader_material = get_material() 

func _process(_delta):
	# Ensure the shader material is attached
	if shader_material is ShaderMaterial:
		
		var global_pos = global_position
		var viewport_size = get_viewport().size
		
		# --- FIX FOR XFORM_POINT ERROR ---
		# Get the transform that converts world coordinates to screen/canvas coordinates.
		# This is the most reliable way in Godot 4.
		var world_to_screen = get_viewport().get_canvas_transform()
		
		# Apply the inverse transform to get the screen position (pixels)
		var screen_pos = world_to_screen.xform(global_pos)
		# ----------------------------------
		
		# Normalize the screen position (convert pixels to 0.0 - 1.0 range)
		var normalized_center = screen_pos / viewport_size
		
		# Pass the dynamic center to the shader uniform
		shader_material.set_shader_parameter("center", normalized_center)
