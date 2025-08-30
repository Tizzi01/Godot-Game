extends Area2D

func _on_body_entered(body):
	print("Chest touched by:", body.name)
	queue_free()
