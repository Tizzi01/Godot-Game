extends Area2D

@export var push_force := 800.0

func _ready():
	$AnimationPlayer.play("expand")
	connect("body_entered", _on_body_entered)
	$Timer.timeout.connect(queue_free)

func _on_body_entered(body):
	if body.is_in_group("Mob") or body.is_in_group("Mob2"):
		var direction = (body.global_position - global_position).normalized()
		if body.has_method("apply_pushback"):
			body.apply_pushback(direction * push_force)
