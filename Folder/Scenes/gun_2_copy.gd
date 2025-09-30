extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var auto_play_animation: String = ""

func _ready() -> void:
	# Center this node on the screen
	var viewport_size = get_viewport().get_visible_rect().size
	global_position = viewport_size / 2

	# Scale all Sprite2D children 5×
	for child in get_children():
		if child is Sprite2D:
			child.scale *= 5.0

	# Optional: auto-play animation
	if auto_play_animation != "" and animation_player:
		animation_player.play(auto_play_animation)
