# EffectController.gd
# ATTACH TO: The full-screen ColorRect (The shader canvas)

extends ColorRect

# This variable will hold a reference to the Sprite2D you drag onto it
@export var sprite_to_follow: Node2D

@onready var shader_material = material

func _process(_delta):
	# Stop if the sprite or shader material isn't set up
	if not sprite_to_follow or not (shader_material is ShaderMaterial):
		return

	# 1. Get the Sprite's position in the game world
	var global_pos = sprite_to_follow.global_position
	var viewport_size = get_viewport().size
	
	# 2. Convert the world position to screen/pixel coordinates
	# This is the crucial step to get the correct screen coordinates
	var world_to_screen_transform = get_viewport().get_canvas_transform()
	var screen_pos = world_to_screen_transform.xform(global_pos)
	
	# 3. Normalize (0.0 to 1.0) the screen position for the shader
	var normalized_center = screen_pos / viewport_size
	
	# 4. Update the shader's 'center' uniform
	shader_material.set_shader_parameter("center", normalized_center)
