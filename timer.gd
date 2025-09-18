extends Control

var total_time_in_secs: int = 0

func _ready():
	# Setup timer
	$Timer.wait_time = 1.0
	$Timer.one_shot = false
	$Timer.start()
	$Timer.timeout.connect(_on_timer_timeout)

	# Connect to game_over_triggered signal from Game node
	var game_node = get_tree().get_root().get_node("Game")
	if game_node and game_node.has_signal("game_over_triggered"):
		game_node.game_over_triggered.connect(_on_game_over_triggered)
	else:
		push_warning("⚠️ Could not connect to 'game_over_triggered' signal. Check node name and signal declaration.")

func _on_timer_timeout():
	total_time_in_secs += 1
	var minutes = total_time_in_secs / 60
	var seconds = total_time_in_secs % 60
	$Label.text = "%02d:%02d" % [minutes, seconds]

func _on_game_over_triggered():
	$Timer.stop()
	print("🛑 Timer stopped due to game over.")
