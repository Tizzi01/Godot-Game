extends CharacterBody2D

var health = 100
var is_glitching := false  # Flag to disable movement during glitch

@onready var gl: AudioStreamPlayer = $GL
@onready var player = get_node("/root/Game/Player")
@onready var animation_player = $AnimationPlayer
@onready var sprites = [ $"0", $"1", $"2" ]  # Visual layers
@onready var hit_flash: AnimationPlayer = $HitFlash
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

signal died

# Teleport logic
var teleport_cooldown := 5.0
var teleport_timer := 0.0

func _ready():
	randomize()

func _physics_process(delta):
	# Movement toward player
	if not is_glitching:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * 150.0
		move_and_slide()
	else:
		velocity = Vector2.ZERO

	# Flip visuals to face player
	var should_flip = player.global_position.x > global_position.x
	for sprite in sprites:
		if sprite:
			sprite.flip_h = should_flip

	# Trigger animation based on movement
	var is_moving = velocity.length() > 0.1
	var current_anim = animation_player.current_animation

	if is_moving and current_anim != "walk":
		animation_player.play("walk")
	elif not is_moving and current_anim != "idle":
		animation_player.play("walk")

	# Teleport logic
	teleport_timer -= delta
	if teleport_timer <= 0.0:
		teleport_timer = teleport_cooldown
		print("⏱ Enemy teleport triggered")
		teleport_near_player()

func take_damage():
	if is_glitching:
		return  # Already glitching out—ignore further damage

	health -= 10
	hit_flash.play("Hitflash")

	if health <= 0:
		died.emit()
		await glitch_out()

func teleport_near_player():
	var space_state = get_viewport().get_world_2d().direct_space_state
	var shape = $CollisionShape2D.shape.duplicate()

	var offset = Vector2(randf_range(-200, 200), randf_range(-200, 200))
	var target_pos = player.global_position + offset

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D.IDENTITY.translated(target_pos)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_shape(query)

	if result.is_empty():
		global_position = target_pos
		print("✅ Enemy teleported directly to:", target_pos)
	else:
		var collision = result[0]
		if collision.has("normal"):
			var push_dir = collision["normal"].normalized()
			var safe_pos = target_pos + push_dir * 10.0
			query.transform = Transform2D.IDENTITY.translated(safe_pos)
			var recheck = space_state.intersect_shape(query)

			if recheck.is_empty():
				global_position = safe_pos
				print("✅ Enemy teleported to safe pushed position:", safe_pos)
			else:
				print("❌ Enemy teleport failed — safe position blocked:", safe_pos)
		else:
			print("❌ Enemy teleport failed — no normal in collision result")

func glitch_out():
	is_glitching = true
	animation_player.play("walk")
	gl.play()
	collision_shape_2d.disabled = true

	var original_pos = position
	var original_visibility = visible

	for i in range(6):
		position += Vector2(randf_range(-3, 3), randf_range(-3, 3))
		visible = false
		await get_tree().create_timer(0.03).timeout
		visible = true
		await get_tree().create_timer(0.03).timeout
		position = original_pos

		for sprite in sprites:
			if sprite:
				sprite.modulate = Color(randf(), randf(), randf())

	await get_tree().create_timer(0.1).timeout

	for sprite in sprites:
		if sprite:
			sprite.modulate = Color(1, 1, 1)

	queue_free()
