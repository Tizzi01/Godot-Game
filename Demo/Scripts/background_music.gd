extends AudioStreamPlayer

var fade_duration := 5.0
var fading := false

func _ready():
	stream.loop = true
	play()

	# Connect to the signal from the main scene
	var main_scene = get_tree().current_scene
	if main_scene.has_signal("game_over_triggered"):
		main_scene.connect("game_over_triggered", Callable(self, "_on_game_over"))

func _on_game_over():
	if fading:
		return
	fading = true

	# Fade out using Tween
	var tween := create_tween()
	tween.tween_property(self, "volume_db", -80.0, fade_duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT) 
