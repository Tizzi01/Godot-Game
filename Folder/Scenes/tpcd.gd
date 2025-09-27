extends ProgressBar

func _process(delta):
	if value == 0 or value == max_value:
		modulate.a = 1.0  # Fully visible when empty or full
	else:
		modulate.a = 0.7  # Semi-transparent while charging
