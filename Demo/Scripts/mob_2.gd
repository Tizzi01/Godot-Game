extends CharacterBody2D

var health = 10

@onready var player = get_node("/root/Game/Player")
@onready var animation_player = $AnimationPlayer
@onready var sprites = [ $"0", $"1", $"2" ]  # These are just visuals, not animated individually
@onready var hit_flash: AnimationPlayer = $HitFlash

signal died

# Teleport logic
var teleport_cooldown := 5.0  # seconds between teleports
var teleport_timer := 0.0     # countdown tracker

func _ready():
	randomize()

func _physics_process(delta):
	# Movement toward player
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 100.0
	move_and_slide()

	# Flip visuals to face player
	var should_flip = player.global_position.x < global_position.x
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
	health -= 10
	hit_flash.play("Hitflash")

	if health <= 0:
		died.emit()
		queue_free()
		const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position

func teleport_near_player():
	var space_state = get_viewport().get_world_2d().direct_space_state
	var shape = $CollisionShape2D.shape.duplicate()

	# Random offset near player
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
		hit_flash.play("Hitflash")
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
				hit_flash.play("Hitflash")
				print("✅ Enemy teleported to safe pushed position:", safe_pos)
			else:
				print("❌ Enemy teleport failed — safe position blocked:", safe_pos)
		else:
			print("❌ Enemy teleport failed — no normal in collision result")
