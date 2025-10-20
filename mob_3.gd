extends CharacterBody2D

# State Management
enum State { NORMAL, ZIGZAG_SETUP, DASHING }
var current_state: State = State.NORMAL
# Cache baked ImageTextures by original texture RID to avoid rebaking
var _afterimage_bake_cache: Dictionary = {}
# Core Stats
var health: int = 10
var is_being_pulled: bool = false
var last_known_direction: Vector2 = Vector2.ZERO
var dash_disabled_timer: float = 0.0
# Movement & Dash Tuning
var base_speed: float = 66.0
var current_speed: float = base_speed
var float_offset: Vector2 = Vector2.ZERO
var float_timer: float = 0.0
var is_cleaning_up: bool = false
const DASH_DISTANCE_MULTIPLIER: float = 0.85
const DASH_MAX_TRIES_TO_FIT_CAMERA: int = 8
var dash_duration: float = 0.3

# Zig-Zag State Variables
var zigzag_interval: float = randf_range(3.0, 5.0)
var zigzag_timer: float = 0.0
var zigzag_count: int = 0
var zigzag_max: int = 0
var zigzag_dash_delay: float = 0.07
var zigzag_dash_timer: float = 0.0
var dash_timer: float = 0.0
var dash_start: Vector2 = Vector2.ZERO
var dash_target: Vector2 = Vector2.ZERO
var last_dash_direction: Vector2 = Vector2.ZERO

# Scene References & visuals
@onready var player: Node2D = get_node("/root/Game/Player")
@onready var camera: Camera2D = get_viewport().get_camera_2d()
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitflash: AnimationPlayer = $hitflash
var sprites: Array = []
signal died

# ====================
# AFTERIMAGE CONFIG (single master control)
# ====================

# Master density control: 0.0 = sparse, 1.0 = dense
var afterimage_density: float = 0.7

# Internal mapping bounds (you normally won't change these)
var _afterimage_min_interval: float = 0.01   # smallest interval between spawns (dense)
var _afterimage_max_interval: float = 0.14   # largest interval between spawns (sparse)
var _afterimage_max_burst: int = 8           # max burst size at slow parts
var _afterimage_min_burst: int = 1           # min burst at fast parts

# Afterimage visuals
var afterimage_enabled: bool = true
var afterimage_life: float = 0.45
var afterimage_start_alpha: float = 0.35
var afterimage_scale: float = 1.0

# timers and tracking
var afterimage_timer: float = 0.0
var prev_eased_t: float = 0.0


func _ready() -> void:
	add_to_group("Mob3")
	print("✅ Mob3 added to group 'Mob3'") 
	randomize()

	# Sprite Lookup
	for name in ["0", "1", "2"]:
		var s = get_node_or_null(name)
		if s:
			sprites.append(s)
	if sprites.is_empty():
		for child in get_children():
			if child is Sprite2D:
				sprites.append(child)

	# Game Over Signal Connection
	var game_node = get_tree().get_root().get_node("Game")
	if game_node:
		game_node.game_over_triggered.connect(_on_game_over_triggered)

	current_state = State.NORMAL

var push_velocity: Vector2 = Vector2.ZERO
var pushback_active: bool = false

func _physics_process(delta: float) -> void:
	
	if pushback_active:
		velocity = push_velocity
		move_and_slide()
		velocity = Vector2.ZERO
		return
	if dash_disabled_timer > 0.0:
		dash_disabled_timer -= delta
		current_state = State.NORMAL
	if is_being_pulled:
		move_and_slide()
		return

	_update_floaty_offset(delta)
	var move_direction: Vector2 = _get_move_direction()
	var should_flip: bool = _update_sprite_flip()

	if dash_disabled_timer > 0.0:
		dash_disabled_timer -= delta
		_state_normal(delta, move_direction)
	else:
		match current_state:
			State.NORMAL:
				_state_normal(delta, move_direction)
			State.ZIGZAG_SETUP:
				_state_zigzag_setup(delta, move_direction, should_flip)
			State.DASHING:
				_state_dashing(delta, should_flip)

	_update_animation()

func _update_floaty_offset(delta: float) -> void:
	float_timer += delta
	float_offset = Vector2(sin(float_timer * 2.5), cos(float_timer * 2.0)) * 18.0

func _get_move_direction() -> Vector2:
	if not player.is_hidden_from_mobs:
		var dir = global_position.direction_to(player.global_position)
		last_known_direction = dir
		return dir
	return last_known_direction

func _update_sprite_flip() -> bool:
	var should_flip: bool = player.global_position.x < global_position.x
	for s in sprites:
		if s and "flip_h" in s:
			s.flip_h = should_flip
	return should_flip

func _state_normal(delta: float, move_direction: Vector2) -> void:
	velocity = (move_direction * current_speed) + float_offset
	move_and_slide()
	velocity = Vector2.ZERO

	zigzag_timer += delta
	if zigzag_timer >= zigzag_interval:
		current_state = State.ZIGZAG_SETUP
		zigzag_timer = 0.0
		zigzag_count = 0
		zigzag_max = randi() % 3 + 3
		zigzag_dash_timer = 0.0
		zigzag_interval = randf_range(3.0, 5.0)
		afterimage_timer = 0.0
		prev_eased_t = 0.0

func _state_zigzag_setup(delta: float, move_direction: Vector2, should_flip: bool) -> void:
	zigzag_dash_timer += delta
	if zigzag_dash_timer < zigzag_dash_delay:
		return
	zigzag_dash_timer = 0.0

	if zigzag_count >= zigzag_max:
		current_state = State.NORMAL
		return

	var manager = get_node("/root/DashManager")
	if not manager or not manager.has_method("register_dasher"):
		print("❌ [Mob3] DashManager missing or broken")
		current_state = State.NORMAL
		return

	var success = manager.register_dasher(self)
	if not success:
		current_state = State.NORMAL
		return

	var dash_dir: Vector2 = _get_safe_dash_direction(move_direction)
	if dash_dir == Vector2.ZERO:
		current_state = State.NORMAL
		return

	var desired_distance: float = current_speed * 4.0 * DASH_DISTANCE_MULTIPLIER
	var future_pos: Vector2 = global_position + dash_dir.normalized() * desired_distance
	var attempts: int = 0

	while attempts < DASH_MAX_TRIES_TO_FIT_CAMERA and not is_position_in_camera(future_pos):
		desired_distance *= 0.8
		future_pos = global_position + dash_dir.normalized() * desired_distance
		attempts += 1

	if desired_distance < 8.0:
		current_state = State.NORMAL
		return

	dash_start = global_position
	dash_target = future_pos
	last_dash_direction = dash_dir.normalized()
	dash_timer = dash_duration * (base_speed / current_speed)
	zigzag_count += 1
	current_state = State.DASHING
	prev_eased_t = 0.0
	afterimage_timer = 0.0

func _state_dashing(delta: float, should_flip: bool) -> void:
	if not DashManager.can_dash:
		print("🚫 [Mob3] In DASHING state without permission:", name)
		current_state = State.NORMAL
		return
	# Movement (local easing)
	dash_timer -= delta
	var raw_t: float = clamp(1.0 - (dash_timer / dash_duration), 0.0, 1.0)
	var eased_t: float = ease_in_out(raw_t)
	global_position = dash_start.lerp(dash_target, eased_t)

	# derivative-based speed factor (0 slow/start/end → 1 fast/mid)
	var deriv: float = 6.0 * eased_t * (1.0 - eased_t)
	var speed_factor: float = clamp(deriv / 1.5, 0.0, 1.0)

	# Map master density to interval and burst ranges
	var mapped_interval: float = lerp(_afterimage_max_interval, _afterimage_min_interval, clamp(afterimage_density, 0.0, 1.0))
	var burst_min_f: float = lerp(float(_afterimage_min_burst), float(_afterimage_max_burst), clamp(afterimage_density, 0.0, 1.0))
	var burst_max_f: float = lerp(float(_afterimage_min_burst), float(_afterimage_max_burst), clamp(afterimage_density, 0.0, 1.0))

	# Choose burst size: more when slow (speed_factor small)
	var burst_count: int = int(round(lerp(burst_max_f, burst_min_f, speed_factor)))
	burst_count = max(1, burst_count)

	# Guarantee at least N images through the dash depending on density
	var guarantee_images_mid: int = max(1, int(round(lerp(1.0, 6.0, clamp(afterimage_density, 0.0, 1.0)))))
	var min_interval_for_mid_images: float = dash_duration / float(guarantee_images_mid)
	var effective_interval: float = min(mapped_interval, min_interval_for_mid_images)

	# Spawn afterimages using adaptive interval and bursts
	if afterimage_enabled:
		afterimage_timer += delta
		if afterimage_timer >= effective_interval:
			afterimage_timer = 0.0
			for i in range(burst_count):
				_spawn_afterimage()

	# Transition Check
	if dash_timer <= 0.0:
		if zigzag_count >= zigzag_max:
			current_state = State.NORMAL
		else:
			current_state = State.ZIGZAG_SETUP

	prev_eased_t = eased_t



func _get_safe_dash_direction(move_direction: Vector2) -> Vector2:
	var tries: int = 0
	while tries < 10:
		var angle_offset: float = deg_to_rad(randf_range(-60, 60))
		var candidate: Vector2 = move_direction.rotated(angle_offset)
		if last_dash_direction != Vector2.ZERO:
			var dot: float = candidate.dot(-last_dash_direction)
			if dot > 0.7:
				tries += 1
				continue

		var dist: float = global_position.distance_to(player.global_position)
		if dist < 100:
			return -candidate
		return candidate
	return Vector2.ZERO

func _update_animation() -> void:
	var is_moving: bool = current_state == State.DASHING or velocity.length() > 0.1
	var current_anim = animation_player.current_animation
	if is_moving and current_anim != "walk":
		animation_player.play("walk")
	elif not is_moving and current_anim != "idle":
		animation_player.play("idle")

func take_damage(amount: int = 10) -> void:
	health -= amount
	print("💥 Mob3 took damage. Health now:", health)

	if hitflash and hitflash.has_animation("hitflash"):
		hitflash.play("hitflash")

	if health <= 0:
		print("☠️ Mob3 health <= 0. Emitting 'died' signal.")
		died.emit()

		# 🧹 Release dash powers if this mob was the dasher
		if DashManager.can_dash:
			print("🧹 [Mob3] Releasing dash on death:", name, "| ID:", get_instance_id())

			var manager = get_node("/root/DashManager")
			if manager and manager.has_method("release_dasher"):
				manager.release_dasher(self)

		delayed_cleanup()

		const SMOKE_SCENE := preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke := SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position

func _on_game_over_triggered() -> void:
	if DashManager.can_dash:
		var manager = get_node("/root/DashManager")
		if manager and manager.has_method("release_dasher"):
			manager.release_dasher(self)

	queue_free()

func _spawn_afterimage() -> void:
	# pick first Sprite2D child as visual source
	var src: Sprite2D = null
	for c in sprites:
		if c and c is Sprite2D:
			src = c as Sprite2D
			break
	if src == null:
		return

	# create afterimage sprite and copy transform/flip/scale/z
	var ai: Sprite2D = Sprite2D.new()
	ai.global_position = global_position
	ai.z_index = src.z_index - 1
	ai.flip_h = src.flip_h if "flip_h" in src else false
	ai.scale = src.scale * afterimage_scale

	# Attempt to bake a texture from the source texture's Image (fast path when supported)
	var baked_tex: Texture2D = null
	var tex := src.texture if src.texture is Texture2D else null
	if tex != null:
		var rid_key = tex.get_rid()
		if _afterimage_bake_cache.has(rid_key):
			baked_tex = _afterimage_bake_cache[rid_key]
		else:
			# try to get an Image from common methods
			var img: Image = null
			if "get_image" in tex:
				img = tex.get_image()
			elif "get_data" in tex:
				img = tex.get_data()
			# If we obtained an Image, bake desired start alpha into it
			if img:
				img = img.duplicate()
				# ensure format with alpha
				img.convert(Image.FORMAT_RGBA8)
				var rect: Rect2 = img.get_used_rect()
				var a_factor: float = clamp(afterimage_start_alpha, 0.0, 1.0)
				for y in range(int(rect.position.y), int(rect.position.y + rect.size.y)):
					for x in range(int(rect.position.x), int(rect.position.x + rect.size.x)):
						var c: Color = img.get_pixel(x, y)
						c.a = c.a * a_factor
						img.set_pixel(x, y, c)
				var it: ImageTexture = ImageTexture.create_from_image(img)
				baked_tex = it
				_afterimage_bake_cache[rid_key] = baked_tex
				print("Afterimage: BAKED for texture RID ", rid_key)

	# assign texture and initial modulate
	if baked_tex != null:
		ai.texture = baked_tex
		ai.modulate = Color(1, 1, 1, 1)  # texture already has baked alpha; keep rgb neutral
	else:
		# fallback: use source texture and set sprite modulate alpha (may be affected by source shader/material)
		ai.texture = src.texture
		var base_col: Color = Color(1, 1, 1, 1)
		if typeof(src.modulate) == TYPE_COLOR:
			base_col = src.modulate
		ai.modulate = Color(base_col.r, base_col.g, base_col.b, afterimage_start_alpha)
		print("Afterimage: FALLBACK modulate (texture type may not expose image)")

	# Ensure no material interferes on afterimage so modulate works
	ai.material = null

	get_parent().add_child(ai)

	# Enforce start alpha (covers baked and fallback cases)
	ai.modulate = Color(ai.modulate.r, ai.modulate.g, ai.modulate.b, afterimage_start_alpha)

	# fade alpha to zero and free
	var tw := create_tween()
	tw.tween_property(ai, "modulate:a", 0.0, afterimage_life).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(afterimage_life).timeout
	if is_instance_valid(ai) and ai.is_inside_tree():
		ai.queue_free()

func _screen_rect_size() -> Vector2:
	if camera == null:
		return Vector2.ZERO
	var raw_zoom = camera.zoom
	var view_size: Vector2 = camera.get_viewport_rect().size
	if typeof(raw_zoom) == TYPE_VECTOR2:
		return view_size * (raw_zoom as Vector2)
	else:
		var z = float(raw_zoom)
		return view_size * Vector2(z, z)

func is_position_in_camera(pos: Vector2) -> bool:
	if camera == null:
		return true
	var screen_size: Vector2 = _screen_rect_size()
	var screen_center: Vector2 = camera.global_position
	var screen_rect: Rect2 = Rect2(screen_center - screen_size * 0.5, screen_size)
	return screen_rect.has_point(pos)

func ease_in_out(t: float) -> float:
	var p = t - 1.0
	return 1.0 - p * p * p * p
	
func apply_slowdown(duration: float = 5.0, slow_percent: float = 0.1) -> void:
	dash_disabled_timer = 8.0
	current_speed *= slow_percent
	await get_tree().create_timer(duration).timeout
	current_speed = base_speed

func apply_pushback(force: Vector2) -> void:
	if force.length() > 150.0:
		push_velocity = force.normalized() * 150.0
	else:
		push_velocity = force

	pushback_active = true

	var tween = create_tween()
	tween.tween_property(self, "push_velocity", Vector2.ZERO, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.finished.connect(_on_pushback_finished)  
	
func _on_pushback_finished() -> void:
	pushback_active = false
	
func try_become_dasher() -> void:
	if DashManager.can_dash:
		print("⚠️ Already has dash permission:", name)
		return

	var manager = get_node("/root/DashManager")
	if manager and manager.has_method("register_dasher"):
		var success = manager.register_dasher(self)
		if success:
			print("✅ Dash permission granted to:", name)
		else:
			print("❌ Dash permission denied to:", name) 
			
			
func delayed_cleanup() -> void: 
	
	if is_cleaning_up:
		return
	is_cleaning_up = true
	# Disable visibility
	visible = false

	# Stop physics
	set_physics_process(false)

	# Disable collision layers and masks
	set_collision_layer(0)
	set_collision_mask(0)

	# Disable all CollisionShape2D children
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true

	# Optional: stop animations
	if animation_player:
		animation_player.stop()

	# Wait 3 seconds before freeing
	await get_tree().create_timer(3.0).timeout
	queue_free()
