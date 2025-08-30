extends Node2D

var health := 100

func take_damage(amount: int) -> void:
	health -= amount
	print("Took damage:", amount, "Remaining health:", health)
	if health <= 0:
		die()

func die() -> void:
	print("Character has died.")
	# You could play an animation, remove the node, etc. 
