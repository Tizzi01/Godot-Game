extends AudioStreamPlayer

const SFX = preload("res://Demo Game/The assets/music/ClickSound.mp3")

func _ready():
	volume_db = -22.0  # Set volume in decibels (0.0 = full volume)
	stream = SFX   # Assign the preloaded music to the stream
	play()           # Start playing the music

func _on_Level_level():
	stream = SFX   # Reassign the stream (optional if already set)
	play()           # Play the music again
