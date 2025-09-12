extends Node  # ✅ Must be Node



var click_sound := preload("res://Demo Game/The assets/music/Click4.mp3")
var player := AudioStreamPlayer.new()

func _ready():
	player.stream = click_sound
	player.volume_db = -12.0  # 🎚️ Lower the volume here
	add_child(player)

func play_ClickSound():
	player.play()
