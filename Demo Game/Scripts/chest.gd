extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":  # Or use group check
		print("Chest touched by:", body.name)
		
		# Give sword
		var sword = body.get_node("m1")
		sword.visible = true
		sword.set_process(true)  # Optional: re-enable logic
		
		# Optional: play pickup animation or sound
		queue_free()  # Remove chest
