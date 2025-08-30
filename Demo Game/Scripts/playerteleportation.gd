extends CharacterBody2D




@export var walk_speed = 150.0
@export var run_speed = 250.0
@export_range(0,1) var acceleration = 0.1
@export_range(0,1) var decceleration = 0.1


@export var jump_force = -300.0
@export_range(0,1) var deccelerate_on_jump_release = 0.5


@export var dash_speed = 500.0
@export var dash_max_distance = 75.0
@export var dash_curve : Curve
@export var dash_cooldown = 0.5


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


var is_dashing = false
var dash_start_position = 0
var dash_direction = 0
var dash_timer = 0


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta


	var speed
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = walk_speed


	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * decceleration)
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall()):
		velocity.y = jump_force


	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= deccelerate_on_jump_release


	# Dash activation
	if Input.is_action_just_pressed("dash") and direction and not is_dashing and dash_timer <= 0:
		is_dashing = true
		dash_start_position = position.x
		dash_direction = direction
		dash_timer = dash_cooldown


	# Performs Dash
	if is_dashing:
			var current_distance = abs(position.x - dash_start_position)
			if current_distance >= dash_max_distance or is_on_wall():
				is_dashing = false
			else:
				velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
				velocity.y = 0
   
	# Reduces dash timer
	if dash_timer > 0:
		dash_timer -= delta


	move_and_slide()




   
