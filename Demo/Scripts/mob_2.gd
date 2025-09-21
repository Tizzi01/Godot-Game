extends CharacterBody2D

var move_speed := 150.0
var health := 70
var is_glitching := false
var is_teleporting := false

@onready var gl: AudioStreamPlayer = $GL
@onready var zero: AudioStreamPlayer = $Zero
@onready var player = get_node("/root/Game/Player")
@onready var animation_player = $AnimationPlayer
@onready var sprites = [ $"0", $"1", $"2" ]
@onready var hit_flash: AnimationPlayer = $HitFlash
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

signal died

var teleport_cooldown := 5.0
var teleport_timer := 0.0

func _ready():
# Inside _ready()
	if $"2":
		$"2".modulate = Color(1, 1, 1, 0.5)
	add_to_group("Mob2")

	var speed_options = [150.0, 200.0, 250.0, 300.0]
	move_speed = speed_options[randi() % speed_options.size()]

	if move_speed == 150.0:
		health = 60
	elif move_speed == 200.0:
		health = 50
	elif move_speed == 250.0:
		health = 40
	elif move_speed == 300.0:
		health = 30

	var game_node = get_tree().get_root().get_node("Game")
	if game_node:
		game_node.game_over_triggered.connect(_on_game_over_triggered)

func _physics_process(delta):
	if not is_glitching and not is_teleporting:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

	var should_flip = player.global_position.x > global_position.x
	for sprite in sprites:
		if sprite:
			sprite.flip_h = should_flip

	var is_moving = velocity.length() > 0.1
	var current_anim = animation_player.current_animation

	if is_moving or is_teleporting:
		if current_anim != "walk":
			animation_player.play("walk")
	elif not is_moving and current_anim != "idle":
		animation_player.play("walk")

	teleport_timer -= delta
	if teleport_timer <= 0.0 and TeleportManager.can_teleport:
		if can_attempt_teleport():
			teleport_timer = teleport_cooldown
			await teleport_near_player()

func can_attempt_teleport() -> bool:
	return not is_glitching and health > 12 and not is_too_close_to_player()

func is_too_close_to_player() -> bool:
	return global_position.distance_to(player.global_position) < 60.0

func take_damage():
	if is_glitching:
		return

	health -= 10
	hit_flash.play("Hitflash")

	if health <= 0:
		died.emit()
		await glitch_out()

func teleport_near_player():
	TeleportManager.start_cooldown()

	var space_state = get_viewport().get_world_2d().direct_space_state
	var shape = $CollisionShape2D.shape.duplicate()

	var angle = randf() * TAU
	var distance = randf_range(60.0, 120.0)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	var target_pos = player.global_position + offset

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D.IDENTITY.translated(target_pos)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_shape(query)

	if result.is_empty():
		global_position = target_pos
		await tp_glitch()
	else:
		var collision = result[0]
		if collision.has("normal"):
			var push_dir = collision["normal"].normalized()
			var safe_pos = target_pos + push_dir * 5.0
			query.transform = Transform2D.IDENTITY.translated(safe_pos)
			var recheck = space_state.intersect_shape(query)

			if recheck.is_empty():
				global_position = safe_pos
				await tp_glitch()

func tp_glitch():
	is_teleporting = true
	zero.play()

	var camera := get_viewport().get_camera_2d()
	if camera and camera.has_method("add_glitch_trauma"):
		camera.add_glitch_trauma(0.5)

	var original_pos = position

	for i in range(4):
		visible = false
		await get_tree().create_timer(0.025).timeout
		visible = true
		await get_tree().create_timer(0.025).timeout
		position += Vector2(randf_range(-2, 2), randf_range(-2, 2))

		for sprite in sprites:
			if sprite:
				var alpha = 1.0
				if sprite == $"2":
					alpha = 0.5

				var r = 0.4
				var g = 0.0
				var b = 0.6
				if i % 2 != 0:
					r = 0.2
					g = 0.4
					b = 1.0

				sprite.modulate = Color(r, g, b, alpha)

	is_teleporting = false

	for i in range(2):
		visible = false
		await get_tree().create_timer(0.03).timeout
		visible = true
		await get_tree().create_timer(0.03).timeout
		position += Vector2(randf_range(-2, 2), randf_range(-2, 2))

		for sprite in sprites:
			if sprite:
				var alpha = 1.0
				if sprite == $"2":
					alpha = 0.5

				var r = 0.4
				var g = 0.0
				var b = 0.6
				if i % 2 != 0:
					r = 0.2
					g = 0.4
					b = 1.0

				sprite.modulate = Color(r, g, b, alpha)

	position = original_pos
	await get_tree().create_timer(0.1).timeout

	for sprite in sprites:
		if sprite:
			var alpha = 1.0
			if sprite == $"2":
				alpha = 0.5
			sprite.modulate = Color(1, 1, 1, alpha)

func play_glitch_animation():
	var original_pos = position

	for i in range(6):
		position += Vector2(randf_range(-3, 3), randf_range(-3, 3))
		visible = false
		await get_tree().create_timer(0.03).timeout
		visible = true
		await get_tree().create_timer(0.03).timeout
		position = original_pos

		for sprite in sprites:
			if sprite:
				var alpha = 1.0
				if sprite == $"2":
					alpha = 0.5
				sprite.modulate = Color(randf(), randf(), randf(), alpha)

	await get_tree().create_timer(0.1).timeout

	for sprite in sprites:
		if sprite:
			var alpha = 1.0
			if sprite == $"2":
				alpha = 0.5
			sprite.modulate = Color(1, 1, 1, alpha)

func glitch_out():
	is_glitching = true
	animation_player.play("walk")
	gl.play()
	collision_shape_2d.disabled = true

	await play_glitch_animation()
	queue_free()

func _on_game_over_triggered():
	print("💥 Mob2 removed on game over:", name)
	queue_free()
