extends Area2D

@onready var omni: AudioStreamPlayer = $Omni

var hold_timer := 0.0
var hold_threshold := 4.0
var has_spawned := false

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("slash"):
		hold_timer += delta
		if hold_timer >= hold_threshold and not has_spawned:
			var power = preload("res://Demo/Scenes/power.tscn").instantiate()
			power.global_position = get_global_mouse_position()
			get_tree().current_scene.add_child(power)
			has_spawned = true
	elif Input.is_action_just_released("slash"):
		hold_timer = 0.0
		has_spawned = false

func play_change_animation():
	var anim = get_node_or_null("AnimationPlayer")
	if anim:
		anim.play("change")
	if omni:
		omni.play()
