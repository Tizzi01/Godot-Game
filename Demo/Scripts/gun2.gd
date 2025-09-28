extends Area2D

@onready var omni: AudioStreamPlayer = $Omni

func _physics_process(delta: float) -> void:
	

	if Input.is_action_just_pressed("slash"):

		var power = preload("res://Demo/Scenes/power.tscn").instantiate()

		power.global_position = get_global_mouse_position()

		get_tree().current_scene.add_child(power)

func play_change_animation():
	var anim = get_node_or_null("AnimationPlayer")
	if anim:
		anim.play("change")
	if omni:
		omni.play()
