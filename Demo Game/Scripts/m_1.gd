extends Node2D

@export var follow_radius: float = 20.0
@export var follow_speed: float = 10.0

var player_position: Vector2 = Vector2.ZERO
var mouse_position: Vector2 = Vector2.ZERO

func _process(delta):
	print("M1 is alive")  # Debug print

	var to_mouse = mouse_position - player_position
	if to_mouse.length() > follow_radius:
		to_mouse = to_mouse.normalized() * follow_radius

	var target_pos = player_position + to_mouse
	global_position = global_position.lerp(target_pos, follow_speed * delta)
