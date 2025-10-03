extends CharacterBody2D

# 🧠 Core Stats
var health := 10
var last_known_direction := Vector2.ZERO
var is_being_pulled := false

# 🐌 Slowdown System
var is_slowed := false
var slow_timer := 0.0
var original_speed := 100.0
var current_speed := 100.0

# 💨 Pushback System
var push_velocity := Vector2.ZERO
var pushback_active := false

# 🎮 Scene Connections
@onready var player = get_node("/root/Game/Player")
@onready var animation_player = $AnimationPlayer
@onready var sprites = [ $"0", $"1", $"2" ]
@onready var hit_flash: AnimationPlayer = $HitFlash

# 📢 Signals
signal died

func _ready():
	add_to_group("Mob")

	var game_node = get_tree().get_root().get_node("Game")
	if game_node:
		game_node.game_over_triggered.connect(_on_game_over_triggered)

func _physics_process(delta):
	# 💨 Handle Pushback
	if pushback_active:
		position += push_velocity * delta
		return

	# 🐌 Handle Slowdown Recovery
	if is_slowed:
		slow_timer -= delta
		if slow_timer <= 0.0:
			is_slowed = false
			current_speed = original_speed
		else:
			var t = 1.0 - (slow_timer / 5.0)
			current_speed = lerp(original_speed * 0.1, original_speed, t)

	# 🧭 Movement Logic
	var move_direction := Vector2.ZERO

	if not is_being_pulled:
		if not player.is_hidden_from_mobs:
			move_direction = global_position.direction_to(player.global_position)
			last_known_direction = move_direction
		else:
			move_direction = last_known_direction

		velocity += move_direction * current_speed

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
	hit_flash.play("Hitflash")

	if health <= 0:
		died.emit()
		queue_free()

		const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position

func apply_slowdown(duration: float = 5.0, slow_percent: float = 0.1):
	if is_slowed:
		return

	is_slowed = true
	slow_timer = duration
	original_speed = current_speed
	current_speed *= slow_percent

func apply_pushback(force: Vector2):
	push_velocity = force
	pushback_active = true

	var tween = create_tween()
	tween.tween_property(self, "push_velocity", Vector2.ZERO, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.finished.connect(func():
		pushback_active = false
	)

func _on_game_over_triggered():
	queue_free()
