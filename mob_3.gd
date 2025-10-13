extends CharacterBody2D

# 🧠 Core Stats
var health := 70
var is_being_pulled := false
var last_known_direction := Vector2.ZERO

# 🐌 Floaty Movement
var base_speed := 66.0
var current_speed := base_speed
var float_offset := Vector2.ZERO
var float_timer := 0.0

# 💨 Zig-Zag Dash System
var zigzag_active := false
var zigzag_interval := randf_range(3.0, 5.0)
var zigzag_timer := 0.0
var zigzag_count := 0
var zigzag_max := 0
var zigzag_dash_delay := 0.07
var zigzag_dash_timer := 0.0
var dash_duration := 0.3
var dash_timer := 0.0
var is_dashing := false
var dash_start := Vector2.ZERO
var dash_target := Vector2.ZERO
var last_dash_direction := Vector2.ZERO

# 🎮 Scene Connections
@onready var player = get_node("/root/Game/Player")
@onready var camera := get_viewport().get_camera_2d()
@onready var animation_player = $AnimationPlayer
@onready var sprites = [ $"0", $"1", $"2" ]
@onready var hitflash: AnimationPlayer = $hitflash

# 📢 Signals
signal died

func _ready():
	add_to_group("Mob3")
	randomize()

	var game_node = get_tree().get_root().get_node("Game")
	if game_node:
		game_node.game_over_triggered.connect(_on_game_over_triggered)

func is_position_in_camera(pos: Vector2) -> bool:
	if not camera:
		return true
	var screen_size = camera.get_viewport_rect().size * camera.zoom
	var screen_center = camera.global_position
	var screen_rect = Rect2(screen_center - screen_size * 0.5, screen_size)
	return screen_rect.has_point(pos)

func ease_in_out(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)

func _physics_process(delta):
	if is_being_pulled:
		return

	# 🌀 Amplified Floaty Offset
	float_timer += delta
	float_offset = Vector2(sin(float_timer * 2.5), cos(float_timer * 2.0)) * 18.0

	# 🧭 Movement Direction
	var move_direction := Vector2.ZERO
	if not player.is_hidden_from_mobs:
		move_direction = global_position.direction_to(player.global_position)
		last_known_direction = move_direction
	else:
		move_direction = last_known_direction

	# ⏱️ Dash Trigger
	zigzag_timer += delta
	if not zigzag_active and zigzag_timer >= zigzag_interval:
		zigzag_active = true
		zigzag_timer = 0.0
		zigzag_count = 0
		zigzag_max = randi() % 3 + 3
		zigzag_dash_timer = 0.0
		zigzag_interval = randf_range(3.0, 5.0)

	# 💨 Dash Execution
	if zigzag_active:
		if not is_dashing:
			zigzag_dash_timer += delta
			if zigzag_dash_timer >= zigzag_dash_delay:
				zigzag_dash_timer = 0.0
				if zigzag_count < zigzag_max:
					var dash_dir = Vector2.ZERO
					var tries = 0
					while tries < 10:
						var angle_offset = deg_to_rad(randf_range(-60, 60))
						var candidate = move_direction.rotated(angle_offset)
						if last_dash_direction != Vector2.ZERO:
							var dot = candidate.dot(-last_dash_direction)
							if dot > 0.7:
								tries += 1
								continue
						dash_dir = candidate
						break

					var dist = global_position.distance_to(player.global_position)
					if dist < 100:
						dash_dir = -dash_dir

					var future_pos = global_position + dash_dir * current_speed * 4.0
					if not is_position_in_camera(future_pos):
						return

					dash_start = global_position
					dash_target = future_pos
					last_dash_direction = dash_dir.normalized()
					dash_timer = dash_duration
					is_dashing = true
					zigzag_count += 1
				else:
					zigzag_active = false
		else:
			dash_timer -= delta
			var t = clamp(1.0 - (dash_timer / dash_duration), 0.0, 1.0)
			var eased = ease_in_out(t)
			global_position = dash_start.lerp(dash_target, eased)
			if dash_timer <= 0.0:
				is_dashing = false
	else:
		if not is_dashing:
			velocity = (move_direction * current_speed) + float_offset
			move_and_slide()

	# 🎭 Flip Sprites
	var should_flip = player.global_position.x < global_position.x
	for sprite in sprites:
		if sprite:
			sprite.flip_h = should_flip

	# 🎞️ Play Animation
	var is_moving = velocity.length() > 0.1
	var current_anim = animation_player.current_animation
	if is_moving and current_anim != "walk":
		animation_player.play("walk")
	elif not is_moving and current_anim != "idle":
		animation_player.play("walk")

func take_damage(amount: int = 10) -> void:
	health -= amount
	if hitflash.has_animation("hitflash"):
		hitflash.play("hitflash")

	if health <= 0:
		died.emit()
		queue_free()

		const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position

func _on_game_over_triggered():
	queue_free()

func _draw():
	if camera:
		var screen_size = camera.get_viewport_rect().size * camera.zoom
		var screen_center = camera.global_position
		var screen_rect = Rect2(screen_center - screen_size * 0.5, screen_size)
		draw_rect(screen_rect, Color(1, 0, 0, 0.2), false)
