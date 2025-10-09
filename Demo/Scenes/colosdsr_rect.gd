extends ColorRect 

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_sequence_timer: Timer = $AnimationSequenceTimer

func _ready():
	print("🎞️ Starting animation loop")
	animation_sequence_timer.timeout.connect(_on_animation_tick)
	animation_sequence_timer.wait_time = 0.5
	animation_sequence_timer.one_shot = false
	animation_sequence_timer.start()

func _on_animation_tick():
	animation_player.play("expand")
