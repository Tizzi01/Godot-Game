extends Area2D

const SPEED := 500.0
const RANGE := 35000.0
var travelled_distance := 0.0

func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * SPEED * delta
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body):
	if body and body.is_inside_tree():
		if body.is_in_group("player"):
			queue_free()  # Don't damage player, just remove bullet
			return
		elif body.is_in_group("Mob2"):
			body.take_damage(10, "bullet")
		elif body.has_method("take_damage"):
			body.take_damage(10)
	queue_free()
