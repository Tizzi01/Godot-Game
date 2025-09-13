extends Area2D

var travelled_distance = 0
const SPEED = 1000
const RANGE = 3500

func _ready():
	print("🚀 Bullet Ready:")
	print("→ Starting position:", global_position)
	print("→ Starting rotation (deg):", rad_to_deg(rotation))

func _physics_process(delta: float) -> void:
	position += transform.x * SPEED * delta  # Moves in facing direction

	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
