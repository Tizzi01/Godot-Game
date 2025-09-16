extends ColorRect

signal game_over_glitched

@onready var end: AudioStreamPlayer = %End

func trigger_game_over():
	visible = true
	%End.play()

	var original_pos = position

	for i in range(6):
		visible = false
		await get_tree().create_timer(0.025).timeout
		visible = true
		await get_tree().create_timer(0.025).timeout

		position = original_pos + Vector2(randf_range(-2, 2), randf_range(-2, 2))
		modulate = Color(0.2, 0.6, 1.0) if i % 2 == 0 else Color(0.9, 0.9, 1.0)

	position = original_pos
	modulate = Color(1, 1, 1)

	emit_signal("game_over_glitched")
