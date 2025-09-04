extends Area2D
signal item_acquired

@onready var chest_gone_sfx: AudioStreamPlayer2D = $ChestGoneSFX
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.name == "Player" or (body.has_method("is_in_group") and body.is_in_group("player")):
		var sword := body.get_node_or_null("Game/m_1") 
		if sword:
			sword.visible = true
			sword.set_process(true)
			print("Sword unlocked.")

			# ✅ Get the camera from the player and connect the signal
			var camera := body.get_node_or_null("Camera2D")
			if camera:
				if not is_connected("item_acquired", Callable(camera, "_on_item_acquired")):
					connect("item_acquired", Callable(camera, "_on_item_acquired"))
				emit_signal("item_acquired")
			else:
				push_warning("Player has no Camera2D node.")

		else:
			push_warning("Player has no 'm1' node.")

		animation_player.play("ChestGone")
