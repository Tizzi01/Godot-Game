extends CharacterBody2D

# Core Stats
var health: int = 70
var is_being_pulled: bool = false
var last_known_direction: Vector2 = Vector2.ZERO

# Particles (safe lookup)
@onready var dash_particles_node := $DashParticles
var dash_particles: CPUParticles2D = null
var dash_emission_original: int = 300
var dash_particle_lifetime: float = 1.5

# Floaty movement
var base_speed: float = 66.0
var current_speed: float = base_speed
var float_offset: Vector2 = Vector2.ZERO
var float_timer: float = 0.0

# Zig-zag dash system
var zigzag_active: bool = false
var zigzag_interval: float = randf_range(3.0, 5.0)
var zigzag_timer: float = 0.0
var zigzag_count: int = 0
var zigzag_max: int = 0
var zigzag_dash_delay: float = 0.07
var zigzag_dash_timer: float = 0.0
var dash_duration: float = 0.3
var dash_timer: float = 0.0
var is_dashing: bool = false
var dash_start: Vector2 = Vector2.ZERO
var dash_target: Vector2 = Vector2.ZERO
var last_dash_direction: Vector2 = Vector2.ZERO
var has_emitted_dash_particles: bool = false

# Dash tuning
const DASH_DISTANCE_MULTIPLIER: float = 0.85  # reduce dash distance by 15%
const DASH_MAX_TRIES_TO_FIT_CAMERA: int = 8   # iterative reduction attempts
const EMITTER_OFFSET_DISTANCE: float = 10.0   # how far behind the mob the emitter sits while dashing

# Scene connections
@onready var player: Node2D = get_node("/root/Game/Player")
@onready var camera: Camera2D = get_viewport().get_camera_2d()
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprites: Array = []
@onready var hitflash: AnimationPlayer = $hitflash

signal died

func _ready() -> void:
	add_to_group("Mob3")
	randomize()

	# particles safe lookup and basic setup
	if dash_particles_node and dash_particles_node is CPUParticles2D:
		dash_particles = dash_particles_node as CPUParticles2D
	if dash_particles:
		dash_emission_original = dash_particles.amount
		dash_particles.local_coords = false   # world-space trail
		dash_particle_lifetime = dash_particles.lifetime
		dash_particles.emitting = false

	# sprite lookup (try names then fallback to Sprite2D children)
	for name in ["0", "1", "2"]:
		if has_node(name):
			var s = get_node_or_null(name)
			if s:
				sprites.append(s)
	if sprites.is_empty():
		for child in get_children():
			if child is Sprite2D:
				sprites.append(child)

	var game_node = get_tree().get_root().get_node("Game")
	if game_node:
		game_node.game_over_triggered.connect(_on_game_over_triggered)

# Helper: compute viewport rect size taking Camera2D.zoom being float or Vector2 into account
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
	return t * t * (3.0 - 2.0 * t)

# Place and configure emitter for a dash. emitter will be positioned slightly behind the mob
# so particles spawn trailing the path. This is updated every frame while dashing.
func _position_and_bias_emitter(dash_dir: Vector2, should_flip: bool) -> void:
	if dash_particles == null:
		return
	# dash_dir is normalized; if zero, fallback to facing direction
	var dir: Vector2 = Vector2.ZERO
	if should_flip:
		dir = Vector2(-1, 0)
	else:
		dir = Vector2(1, 0)

	# place emitter slightly behind mob along dash_dir so particles spawn trailing the mob
	var emitter_pos := global_position - dir * EMITTER_OFFSET_DISTANCE
	# set emitter global position (so new particles spawn at correct world point)
	dash_particles.global_position = emitter_pos

	# bias gravity opposite to dash direction so particles drift behind and form a trail
	dash_particles.gravity = -dir * 2000.0

	# If vertical dash (dominant y), nudge emitter to emit from top/bottom edge:
	if abs(dir.y) > abs(dir.x):
		# if moving down (dir.y > 0), put emitter slightly above the mob so particles spawn from top
		if dir.y > 0:
			dash_particles.global_position = global_position - Vector2(0, EMITTER_OFFSET_DISTANCE * 1.2)
		else:
			# moving up: place emitter below mob so particles appear from bottom
			dash_particles.global_position = global_position + Vector2(0, EMITTER_OFFSET_DISTANCE * 1.2)

	# ensure node-level lifetime/amount are reasonable (don't stomp other inspector settings)
	dash_particles.amount = int(dash_emission_original * 0.6)
	dash_particles.lifetime = dash_particle_lifetime

	# If the particle node uses a ParticleProcessMaterial and you want direction control,
	# set its direction vector so initial particle velocities favor dash_dir.
	if dash_particles.process_material and dash_particles.process_material is ParticleProcessMaterial:
		var pm := dash_particles.process_material as ParticleProcessMaterial
		pm.direction = Vector3(dir.x, dir.y, 0)   # favors dash direction
		# leave other pm values set in inspector for visual fidelity

func _start_dash_particles_for(dash_dir: Vector2, should_flip: bool) -> void:
	if dash_particles == null:
		return
	_position_and_bias_emitter(dash_dir, should_flip)
	dash_particles.restart()
	dash_particles.emitting = true

func _stop_dash_particles() -> void:
	if dash_particles == null:
		return
	dash_particles.emitting = false

func _physics_process(delta: float) -> void:
	if is_being_pulled:
		return

	# Floaty offset
	float_timer += delta
	float_offset = Vector2(sin(float_timer * 2.5), cos(float_timer * 2.0)) * 18.0

	# Movement direction (toward player or last known)
	var move_direction: Vector2 = Vector2.ZERO
	if not player.is_hidden_from_mobs:
		move_direction = global_position.direction_to(player.global_position)
		last_known_direction = move_direction
	else:
		move_direction = last_known_direction

	# Flip sprites every frame (same logic as your Mob)
	var should_flip: bool = player.global_position.x < global_position.x
	for s in sprites:
		if s and "flip_h" in s:
			s.flip_h = should_flip

	# Dash trigger
	zigzag_timer += delta
	if not zigzag_active and zigzag_timer >= zigzag_interval:
		zigzag_active = true
		zigzag_timer = 0.0
		zigzag_count = 0
		zigzag_max = randi() % 3 + 3
		zigzag_dash_timer = 0.0
		zigzag_interval = randf_range(3.0, 5.0)
		has_emitted_dash_particles = false

	# Dash execution
	if zigzag_active:
		if not is_dashing:
			zigzag_dash_timer += delta
			if zigzag_dash_timer >= zigzag_dash_delay:
				zigzag_dash_timer = 0.0
				if zigzag_count < zigzag_max:
					# pick a dash direction with some random angle
					var dash_dir: Vector2 = Vector2.ZERO
					var tries: int = 0
					while tries < 10:
						var angle_offset: float = deg_to_rad(randf_range(-60, 60))
						var candidate: Vector2 = move_direction.rotated(angle_offset)
						if last_dash_direction != Vector2.ZERO:
							var dot: float = candidate.dot(-last_dash_direction)
							if dot > 0.7:
								tries += 1
								continue
						dash_dir = candidate
						break

					# if too close, dash backward to create separation
					var dist: float = global_position.distance_to(player.global_position)
					if dist < 100:
						dash_dir = -dash_dir

					# desired dash distance with multiplier
					var desired_distance: float = current_speed * 4.0 * DASH_DISTANCE_MULTIPLIER
					# try to shrink until it fits camera
					var attempts: int = 0
					var future_pos: Vector2 = global_position + dash_dir.normalized() * desired_distance
					while attempts < DASH_MAX_TRIES_TO_FIT_CAMERA and not is_position_in_camera(future_pos):
						desired_distance *= 0.8
						future_pos = global_position + dash_dir.normalized() * desired_distance
						attempts += 1

					# if tiny, skip this dash attempt this frame
					if desired_distance < 8.0:
						pass
					else:
						# start dash with reduced distance if necessary
						dash_start = global_position
						dash_target = future_pos
						last_dash_direction = dash_dir.normalized()
						dash_timer = dash_duration
						is_dashing = true
						zigzag_count += 1

						# start particles using the actual dash direction; emitter will be positioned behind
						if dash_particles and not has_emitted_dash_particles:
							_start_dash_particles_for(last_dash_direction, should_flip)
							has_emitted_dash_particles = true

						# ensure flip just before dash
						for s in sprites:
							if s and "flip_h" in s:
								s.flip_h = should_flip
				else:
					# sequence finished: stop emitting and reset
					zigzag_active = false
					is_dashing = false
					has_emitted_dash_particles = false
					_stop_dash_particles()
		else:
			# performing dash movement
			# update emitter position and gravity every frame so new particles spawn along path (creates smooth bend)
			if last_dash_direction != Vector2.ZERO and dash_particles:
				_position_and_bias_emitter(last_dash_direction, should_flip)

			dash_timer -= delta
			var t: float = clamp(1.0 - (dash_timer / dash_duration), 0.0, 1.0)
			var eased: float = ease_in_out(t)
			global_position = dash_start.lerp(dash_target, eased)
			if dash_timer <= 0.0:
				is_dashing = false
				# After each dash, if we've reached the sequence max, stop particles
				if zigzag_count >= zigzag_max:
					has_emitted_dash_particles = false
					_stop_dash_particles()
				# re-face player
				var should_flip_after: bool = player.global_position.x < global_position.x
				for s in sprites:
					if s and "flip_h" in s:
						s.flip_h = should_flip_after
	else:
		# Resume normal movement when not dashing
		if not is_dashing:
			velocity = (move_direction * current_speed) + float_offset
			move_and_slide()
			velocity = Vector2.ZERO

	# Play animation
	var is_moving: bool = velocity.length() > 0.1
	var current_anim = animation_player.current_animation
	if is_moving and current_anim != "walk":
		animation_player.play("walk")
	elif not is_moving and current_anim != "idle":
		animation_player.play("idle")

func take_damage(amount: int = 10) -> void:
	health -= amount
	if hitflash and hitflash.has_animation("hitflash"):
		hitflash.play("hitflash")
	if health <= 0:
		died.emit()
		queue_free()
		const SMOKE_SCENE := preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke := SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position

func _on_game_over_triggered() -> void:
	queue_free()
