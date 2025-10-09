extends ColorRect

@export var sprite_to_follow: Node2D

@onready var shader_material = material

func _process(_delta):
	if not sprite_to_follow:
		return
		
	if not (shader_material is ShaderMaterial):
		return

	var global_pos = sprite_to_follow.global_position
	var viewport_size = get_viewport().size
	var world_to_screen_transform = get_viewport().get_canvas_transform()
	var screen_pos = world_to_screen_transform.xform(global_pos)
	var normalized_center = screen_pos / viewport_size
	
	shader_material.set_shader_parameter("center", normalized_center)
