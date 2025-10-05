extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer2

func _ready():
	print("🔥 ShockwaveBlast spawned")
	animation_player.play("expand")
	timer.wait_time = 0.5  # Match your animation length
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(queue_free)
