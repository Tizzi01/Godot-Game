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
	if body.has_method("take_damage"):
		body.take_damage()
	queue_free()
