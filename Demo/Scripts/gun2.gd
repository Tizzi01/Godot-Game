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
		if player and player.can_spawn_black_hole():
			hold_timer += delta

			# Only play charge animation and sound once
			if animation_player and animation_player.current_animation != "charge":
				animation_player.play("charge")
				if not up.playing:
					up.play()

			# Spawn black hole if held long enough
			if hold_timer >= hold_threshold and not has_spawned:
				spawn_black_hole()
				has_spawned = true
				player.start_black_hole_cooldown()
		else:
			# Gun is on cooldown — stop animation and sound
			if animation_player and animation_player.current_animation == "charge":
				animation_player.stop()
			if up.playing:
				up.stop()
	else:
		# Released or not holding — stop animation and sound
		if animation_player and animation_player.current_animation == "charge":
			animation_player.stop()
		if up.playing:
			up.stop()

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
