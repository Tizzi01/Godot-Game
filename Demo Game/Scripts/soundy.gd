extends Node

var sounds := {}

func _ready():
	# Preload your sounds once
	sounds["ClickSound"] = preload("res://Demo Game/The assets/music/ClickSound.mp3")

func play_sound(name: String, volume_db: float = 0.0):
	var player = AudioStreamPlayer.new()
	player.stream = sounds.get(name, null)
	if player.stream:
		player.volume_db = volume_db
		add_child(player)
		player.play()
		await player.finished
		player.queue_free()
