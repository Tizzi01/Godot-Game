extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	monitoring = true

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		print("Chest touched by:", body.name)
		
		var sword = body.get_node("gun")
		sword.visible = true
		sword.set_process(true)
		
		queue_free()

func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	rotation = lerp_angle(rotation, direction.angle() - PI / 2, 10 * delta)

	if Input.is_action_just_pressed("slash"):
		$AnimationPlayer.play("slash")

func shoot():
	const BULLET = preload("res://Demo Game/Scenes/Bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %ShootingPoint.global_position
	get_tree().current_scene.add_child(new_bullet)

func _on_timer_timeout() -> void:
	shoot()
