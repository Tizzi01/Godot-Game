extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	animation_player.play("expand")
	get_tree().create_timer(1.0).timeout.connect(queue_free)
