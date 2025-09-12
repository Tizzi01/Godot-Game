extends Panel

func _ready():
	# Start fully white
	modulate = Color(1, 1, 1, 1)

	# Hold the white flash briefly
	await get_tree().create_timer(0.1).timeout  # ⏱ Shorter hold for snappier impact

	# Fade out smoothly
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
