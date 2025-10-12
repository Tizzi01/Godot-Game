extends CharacterBody2D

# 🧠 Core Stats
var health := 10
var last_known_direction := Vector2.ZERO
var is_being_pulled := false

# 🐌 Floaty Movement
var original_speed := 66.0
var current_speed := 66.0
var float_offset := Vector2.ZERO
var float_timer := 0.0

# 💨 Zig-Zag Dash System
var zigzag_active := false
var zigzag_timer := 0.0
var zigzag_interval := randf_range(3.0, 5.0)
var zigzag_count := 0
var zigzag_max := 0
var zigzag_direction := Vector2.ZERO

# 🎮 Scene Connections
@onready var player = get_node("/root/Game/Player")
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

func _physics_process(delta):
	if is_being_pulled:
		return

	# 🌀 Floaty Offset
	float_timer += delta
	float_offset = Vector2(sin(float_timer * 2.0), cos(float_timer * 1.5)) * 10.0

	# ⏱️ Zig-Zag Trigger
	zigzag_timer += delta
	if not zigzag_active and zigzag_timer >= zigzag_interval:
		zigzag_active = true
		zigzag_timer = 0.0
		zigzag_count = 0
		zigzag_max = randi() % 4 + 3  # 3–6 dashes
		zigzag_interval = randf_range(3.0, 5.0)

	# 🧭 Movement Logic
	var move_direction := Vector2.ZERO

	if not player.is_hidden_from_mobs:
		move_direction = global_position.direction_to(player.global_position)
		last_known_direction = move_direction
	else:
		move_direction = last_known_direction

	var final_direction := move_direction

	if zigzag_active:
		# 🧨 Zig-Zag Dash
		if zigzag_count < zigzag_max:
			var angle_offset = deg_to_rad(randf_range(-60, 60))
			zigzag_direction = move_direction.rotated(angle_offset)

			# Keep some distance from player
			var dist = global_position.distance_to(player.global_position)
			if dist < 100:
				zigzag_direction = -zigzag_direction

			velocity = zigzag_direction * current_speed * 2.0
			zigzag_count += 1
		else:
			zigzag_active = false
	else:
		# 🌀 Floaty follow
		velocity = (move_direction * current_speed) + float_offset

	move_and_slide()
	velocity = Vector2.ZERO

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
