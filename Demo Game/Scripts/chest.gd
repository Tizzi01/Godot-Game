extends Area2D

@onready var chest_gone_sfx: AudioStreamPlayer2D = $ChestGoneSFX


func _ready() -> void:
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.name == "Player" or (body.has_method("is_in_group") and body.is_in_group("player")):
		var sword := body.get_node_or_null("m1")
		if sword:
			sword.visible = true
			sword.set_process(true)
			print("Sword unlocked.")
		else:
			push_warning("Player has no 'm1' node.")

		# Play the ChestGone animation
		$AnimationPlayer.play("ChestGone")

		# Connect to animation_finished signal
		$AnimationPlayer.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "ChestGone":
		chest_gone_sfx.play() 
		queue_free()
		
