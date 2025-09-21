extends AudioStreamPlayer

func _ready():
	stream.loop = true  # 🔁 Enable looping
	play()               # ▶️ Start playback
