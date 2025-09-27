extends Area2D

@onready var omni: AudioStreamPlayer = $Omni

func _physics_process(delta: float) -> void:
	print("✅ Gun2 is active and processing")

	if Input.is_action_just_pressed("slash"):
		print("🖱️ Slash input detected — attempting to fire Power bullet")

		var power = preload("res://Demo/Scenes/power.tscn").instantiate()
		print("💥 Power bullet instantiated")

		power.global_position = get_global_mouse_position()
		print("🌍 Power bullet positioned at:", power.global_position)

		get_tree().current_scene.add_child(power)
		print("📦 Power bullet added to scene")

func play_change_animation():
	var anim = get_node_or_null("AnimationPlayer")
	if anim:
		print("🎬 Playing 'change' animation")
		anim.play("change")
	if omni:
		print("🔊 Playing Omni sound")
		omni.play()
