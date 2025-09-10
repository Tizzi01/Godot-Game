extends AudioStreamPlayer

var last_pitch := 1.0

func _input(event):
	if Input.is_action_just_pressed("slash"):
		play_with_variation()

func play_with_variation(from_position := 0.0):
	randomize()
	var new_pitch := randf_range(0.8, 1.2)

	# Ensure the new pitch is noticeably different from the last one
	while abs(new_pitch - last_pitch) < 0.1:
		new_pitch = randf_range(0.8, 1.2)

	last_pitch = new_pitch
	pitch_scale = new_pitch
	play(from_position)
