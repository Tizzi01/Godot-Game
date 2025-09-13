extends Node

var intro_music := preload("res://Demo/Stuff/music/IntroMusic1.mp3")
var player := AudioStreamPlayer.new()
var has_started := false  # Tracks if music has already started

func _ready():
	intro_music.loop = true  # ✅ Enable looping on the stream
	player.stream = intro_music
	player.volume_db = -35.0
	add_child(player)

func play_IntroMusic():
	if not has_started:
		player.play()
		has_started = true

func stop_IntroMusic():
	player.stop()
	has_started = false
