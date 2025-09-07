extends Area2D 

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	monitoring = true
func _on_body_entered(body: Node) -> void:
	if body.name == "Player":  # Or use group check
		print("Chest touched by:", body.name)
		
		# Give sword
		var sword = body.get_node("gun")
		sword.visible = true
		sword.set_process(true)  # Optional: re-enable logic
		
		# Optional: play pickup animation or sound
		queue_free()  # Remove chest  





func _physics_process(delta): 
	monitoring = true 
	var enemies_in_range = get_overlapping_bodies() 
	if enemies_in_range.size() > 0: 
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position) 
		
func shoot():
	const BULLET = preload("res://Demo Game/Scenes/Bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %ShootingPoint.global_position
	get_tree().current_scene.add_child(new_bullet) 


func _on_timer_timeout() -> void:
	shoot() 
