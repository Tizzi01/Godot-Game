extends Control

var total_time_in_secs : int = 0

func _ready():
	$Timer.wait_time = 1.0
	$Timer.one_shot = false
	$Timer.start()
	$Timer.timeout.connect(_on_Timer_timeout)

	# ✅ Connect to game_over_triggered signal
	var game_node = get_tree().get_root().get_node("Game")
	if game_node:
		game_node.game_over_triggered.connect(_on_game_over_triggered)
	else:
		print("⚠️ Could not find Game node to connect signal.")

func _on_Timer_timeout():
	total_time_in_secs += 1
	var minutes = total_time_in_secs / 60
	var seconds = total_time_in_secs % 60
	$Label.text = "%02d:%02d" % [minutes, seconds]

func _on_game_over_triggered():
	$Timer.stop()  # ✅ Stop timer when signal is received
