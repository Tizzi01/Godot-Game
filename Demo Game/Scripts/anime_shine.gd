extends Node

var anime_shine := preload("res://Demo Game/The assets/music/AnimeShine2.mp3")
var player := AudioStreamPlayer.new()

func _ready():
	player.stream = anime_shine
	player.volume_db = -10.0  # 🎚️ Starting volume
	add_child(player)

func play_ClickSound():
	player.play()

	# Wait 2 seconds before starting fade
	await get_tree().create_timer(2.0).timeout

	# Fade out over 1 second (from 2s to 3s)
	var tween := create_tween()
	tween.tween_property(player, "volume_db", -80.0, 1.0) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)
