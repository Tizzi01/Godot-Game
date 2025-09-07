extends Area2D

var travelled_distance := 0.0
const SPEED := 1000.0
const RANGE := 3500.0

func _ready():
	print("bullet_v_2 ready at:", global_position)
	print("Rotation (deg):", rad_to_deg(rotation))

func _physics_process(delta):
	position += transform.x * SPEED * delta
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()
	queue_free()
