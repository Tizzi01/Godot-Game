extends Node2D

@export var health: int = 100

func take_damage(amount: int) -> void:
	if health <= 0:
		return  # Already dead, ignore further damage

	health -= amount
	print("Enemy took damage:", amount)
	print("Remaining health:", health)

	if health > 0:
		if $AnimationPlayer.has_animation("hit1"):
			$AnimationPlayer.play("hit1")
	else:
		print("Enemy defeated!")
		if $AnimationPlayer.has_animation("death"):
			$AnimationPlayer.play("death")
		queue_free()  # Remove enemy from scene
