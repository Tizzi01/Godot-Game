extends Area2D  # or Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
var health := 100

func take_damage(amount: int) -> void:
	health -= amount
	anim_player.play("hit1")
	if health <= 0:
		die()

func die() -> void:
	queue_free()
