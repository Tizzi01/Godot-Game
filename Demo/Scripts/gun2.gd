extends Area2D

@onready var omni: AudioStreamPlayer = $Omni
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var up: AudioStreamPlayer = $up
var is_active := false
var hold_timer := 0.0
var hold_threshold := 1.5
var has_spawned := false

func _physics_process(delta: float) -> void:
	var player = get_tree().get_root().get_node("Game/Player")

	if Input.is_action_pressed("slash"):
		hold_timer += delta

		if player and player.can_spawn_black_hole():
			if animation_player and animation_player.current_animation != "charge":
				animation_player.play("charge")
				up.play()

		if hold_timer >= hold_threshold and not has_spawned and player and player.can_spawn_black_hole():
			spawn_black_hole()
			has_spawned = true
			player.start_black_hole_cooldown()
	else:
		# Let charge animation fade naturally
		pass

	if Input.is_action_just_released("slash"):
		hold_timer = 0.0
		has_spawned = false

func spawn_black_hole():
	var power = preload("res://Demo/Scenes/power.tscn").instantiate()
	power.global_position = get_global_mouse_position()
	get_tree().current_scene.add_child(power)
	power.add_to_group("black")

	var camera = get_tree().get_root().get_node("Game/Player/Camera2D")
	if camera and power.has_signal("black_hole_spawned"):
		power.black_hole_spawned.connect(Callable(camera, "_on_black_hole_spawned"))

	print("🌌 Black hole spawned — cooldown started")

func play_change_animation():
	var anim = get_node_or_null("AnimationPlayer")
	if anim:
		anim.play("change")

	if omni:
		omni.play()
