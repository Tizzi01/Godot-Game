extends AudioStreamPlayer

var last_pitch := 1.0

func play_with_variation(from_position := 0.0):
	randomize()
	var new_pitch := randf_range(0.8, 1.2)

	while abs(new_pitch - last_pitch) < 0.1:
		new_pitch = randf_range(0.8, 1.2)

	last_pitch = new_pitch
	pitch_scale = new_pitch
	play(from_position)
