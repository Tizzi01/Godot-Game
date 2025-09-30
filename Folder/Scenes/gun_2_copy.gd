extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var auto_play_animation: String = ""

func _ready() -> void:
	# Scale all Sprite2D children by exactly 5×
	for child in get_children():
		if child is Sprite2D:
			child.scale = Vector2(5, 5)

	# Optional: auto-play animation
	if auto_play_animation != "" and animation_player:
		animation_player.play(auto_play_animation)
