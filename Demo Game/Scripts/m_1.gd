extends Node2D

@export var max_distance := 200.0  # Max radius from screen center
@export var follow_speed := 10.0   # Smooth follow speed

var is_active := false  # Starts inactive

func _ready():
	visible = false
	set_process(false)
	add_to_group("m1")  # Ensure it's in the correct group

func activate():
	is_active = true
	visible = true
	set_process(true)
	print("🗡️ Sword activated.")

func _process(delta):
	if not is_active:
		return

	var screen_center = get_viewport().get_visible_rect().size / 2
	var mouse_pos = get_global_mouse_position()

	# Clamp target position within radius
	var direction = (mouse_pos - screen_center).normalized()
	var target_distance = min(screen_center.distance_to(mouse_pos), max_distance)
	var target_pos = screen_center + direction * target_distance

	# Smoothly follow the target
	global_position = global_position.lerp(target_pos, follow_speed * delta)

	# Rotate to face the mouse
	rotation = (mouse_pos - global_position).angle()
