extends CharacterBody2D

@export var walk_speed = 150.0
@export var run_speed = 250.0
@export_range(0,1) var acceleration = 0.1
@export_range(0,1) var decceleration = 0.1

@export var jump_force = -300.0
@export_range(0,1) var deccelerate_on_jump_release = 0.5

# dashing
@export var dash_speed = 500.0
@export var dash_max_distance = 75.0
@export var dash_curve : Curve
@export var dash_cooldown = 0.5

var is_dashing = false
var dash_start_position = 0
var dash_direction = 0
var dash_timer = 0

var was_on_floor = true
var is_jumping = false

@export var max_jumps = 99
var jump_count = 0

@onready var sprite: Sprite2D = $PlayerSprite

# teleport hover
var teleporting = false
var teleport_hovering = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_facing_dir = 1

func _physics_process(delta):
	var current_gravity = gravity

	# Hover freeze
	if teleport_hovering:
		velocity = Vector2.ZERO
		current_gravity = 0
		$PlayerSprite/AnimationPlayer.play("Idle")

		# Cancel hover on input
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("dash") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			teleport_hovering = false
			teleporting = false

	# Apply gravity
	if not is_on_floor():
		velocity.y += current_gravity * delta

	var speed = walk_speed
	if Input.is_action_pressed("run"):
		speed = run_speed

	var direction = 0
	if Input.is_action_pressed("left"):
		direction -= 1
	if Input.is_action_pressed("right"):
		direction += 1

	print("Direction: ", direction)

	if direction != 0:
		last_facing_dir = direction

	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * decceleration)

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_force
			jump_count = 1
		elif jump_count < max_jumps:
			velocity.y = jump_force
			jump_count += 1

		if teleporting:
			teleport_hovering = false
			teleporting = false

	if is_on_floor():
		jump_count = 0

	if direction != 0:
		sprite.flip_h = direction < 0

	if Input.is_action_just_pressed("dash") and not is_dashing and dash_timer <= 0:
		is_dashing = true
		dash_start_position = position.x
		dash_direction = last_facing_dir
		dash_timer = dash_cooldown 
		#inactive animation for now
		$PlayerSprite/AnimationPlayer.play("Dsh")  
		

		if teleporting:
			teleport_hovering = false
			teleporting = false

	if is_dashing:
		var current_distance = abs(position.x - dash_start_position)
		if current_distance >= dash_max_distance or is_on_wall():
			is_dashing = false
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			velocity.y = 0

	if dash_timer > 0:
		dash_timer -= delta

	#tp 
	if Input.is_action_just_pressed("tp"):
		var target_pos = get_global_mouse_position()
		var space_state = get_world_2d().direct_space_state
		var shape = $CollisionShape2D.shape.duplicate()

		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D.IDENTITY.translated(target_pos)
		query.collide_with_areas = true
		query.collide_with_bodies = true

		var result = space_state.intersect_shape(query)

		if result.is_empty():
			global_position = target_pos
		else:
			var collision = result[0]
			if collision.has("normal"):
				var push_dir = collision["normal"].normalized()
				var safe_pos = target_pos + push_dir * 10.0

				query.transform = Transform2D.IDENTITY.translated(safe_pos)
				var recheck = space_state.intersect_shape(query)

				if recheck.is_empty():
					global_position = safe_pos
				else:
					print("Blocked! Can't teleport too close to wall.")
			else:
				print("Collision has no normal — skipping safe push.")

		# Start hover
		teleporting = true
		teleport_hovering = true
		velocity = Vector2.ZERO
		$PlayerSprite/AnimationPlayer.play("Idle")

	if is_on_floor() and velocity.x == 0:
		$PlayerSprite/AnimationPlayer.play("Idle")


	move_and_slide() 
