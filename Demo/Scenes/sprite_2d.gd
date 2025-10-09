extends Sprite2D

var is_dragging = false
@onready var color_rect: ColorRect = $".."

func _process(_delta):
	var screen_size := get_viewport().get_visible_rect().size
	var screen_position := get_global_transform_with_canvas().origin
	var normalized_center := screen_position / screen_size

	var mat := $ColorRect.material
	if mat:
		mat.set_shader_parameter("center", normalized_center)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if get_rect().has_point(to_local(event.position)):
				is_dragging = true
		else:
			is_dragging = false
