extends Node  # ✅ Must be Node



var anime_shine := preload("res://Demo/Stuff/music/AnimeShine3.mp3")
var player := AudioStreamPlayer.new()

func _ready():
	player.stream = anime_shine
	player.volume_db = -10.0  # 🎚️ Lower the volume here
	add_child(player)

func play_ClickSound():
	player.play()
