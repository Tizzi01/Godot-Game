extends Area2D

@export var slow_duration := 5.0
@export var slow_percent := 0.1
@export var push_force := 150.0
@export var delay_curve: Curve  # 🎨 Curve resource for animation timing

@onready var luffy: AudioStreamPlayer2D = $luffy
@onready var shockwave_timer: Timer = $ShockwaveTimer
@onready var cleanup_timer: Timer = $Timer
@onready var animation_sequence_timer: Timer = $AnimationSequenceTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Animation timing control
var animation_elapsed := 0.0
var animation_play_count := 0
const ANIMATION_TOTAL_DURATION := 5.0

# Shockwave control
var shockwave_count := 0
var blast_count := 0
const MAX_BLASTS := 4
const BLAST_INTERVAL := 0.3
const LIFETIME := 4.5

func _ready():
	print("🚀 READY: Shockwave node initialized at", global_position)

	# Connect signals
	connect("body_entered", _on_body_entered)
	shockwave_timer.timeout.connect(_on_ShockwaveTimer_timeout)
	animation_sequence_timer.timeout.connect(_on_AnimationSequenceTimer_timeout)

	# Play sound once
	print("🔊 Playing Luffy sound")
	luffy.play()

	# Start animation sequence
	_start_animation_sequence()

	# Trigger first shockwave immediately
	print("⚡ Triggering first shockwave")
	trigger_screen_shockwave()

	# Start shockwave timer
	shockwave_timer.wait_time = BLAST_INTERVAL
	shockwave_timer.start()
	print("⏱️ Shockwave timer started with interval:", BLAST_INTERVAL)

	# Start cleanup timer
	cleanup_timer.wait_time = LIFETIME
	cleanup_timer.start()
	print("🧹 Cleanup timer started with lifetime:", LIFETIME)
	cleanup_timer.timeout.connect(queue_free)

func _start_animation_sequence():
	print("🎞️ Playing expand animation #1 (Initial)")
	animation_player.play("expand")
	animation_play_count = 1
	animation_elapsed = 0.0

	# Start timer with initial delay from curve
	var initial_delay = delay_curve.sample(0.0)
	animation_sequence_timer.one_shot = true
	animation_sequence_timer.wait_time = initial_delay
	animation_sequence_timer.start()
	print("⏱️ Timer started with initial delay:", initial_delay)

func _on_AnimationSequenceTimer_timeout():
	animation_elapsed += animation_sequence_timer.wait_time
	animation_play_count += 1

	if animation_elapsed >= ANIMATION_TOTAL_DURATION:
		print("🛑 Animation sequence complete at", animation_elapsed, "seconds")
		return

	print("🎞️ Playing expand animation #", animation_play_count)
	animation_player.play("expand")

	# Sample next delay from curve
	var t = animation_elapsed / ANIMATION_TOTAL_DURATION
	var next_delay = delay_curve.sample(clamp(t, 0.0, 1.0))

	print("⏱️ Next delay from curve:", next_delay)
	animation_sequence_timer.wait_time = next_delay
	animation_sequence_timer.start()

func _on_ShockwaveTimer_timeout():
	shockwave_count += 1
	print("⏲️ Shockwave timer ticked — count:", shockwave_count)

	if shockwave_count < MAX_BLASTS:
		print("⚡ Triggering shockwave #", shockwave_count + 1)
		trigger_screen_shockwave()
	else:
		print("🛑 Max shockwaves reached — stopping timer")
		shockwave_timer.stop()

func _on_body_entered(body):
	print("💥 Body entered:", body.name)

	if body.is_in_group("Mob") or body.is_in_group("Mob2"):
		var direction = (body.global_position - global_position).normalized()
		print("➡️ Direction to body:", direction)

		if body.has_method("apply_slowdown"):
			print("🐌 Applying slowdown to:", body.name)
			body.apply_slowdown(slow_duration, slow_percent)
		else:
			print("❌ No apply_slowdown method on:", body.name)

		if body.has_method("apply_pushback"):
			print("💨 Applying pushback to:", body.name)
			body.apply_pushback(direction * push_force)
		else:
			print("❌ No apply_pushback method on:", body.name)

		print("⚡ Triggering shockwave from body collision")
		trigger_screen_shockwave()

func trigger_screen_shockwave():
	print("🎬 Triggering screen shockwave")

	var layer = get_tree().get_root().get_node("Game/ShockwaveLayer")
	if layer == null:
		print("❌ ShockwaveLayer not found")
		return

	var effect = layer.get_node("ShockwaveEffect")
	if effect == null:
		print("❌ ShockwaveEffect not found")
		return

	var mat = effect.material
	if mat == null:
		print("❌ Shader material not found")
		return

	var screen_size = get_viewport().get_visible_rect().size
	var normalized_center = global_position / screen_size
	print("📍 Setting shader center:", normalized_center)

	mat.set_shader_parameter("center", normalized_center)
	mat.set_shader_parameter("radius", 0.0)

	var animator = layer.get_node("ShockwaveAnimator")
	if animator == null:
		print("❌ ShockwaveAnimator not found")
		return

	print("🎞️ Playing blast animation #", blast_count + 1)
	animator.stop()
	animator.play("blast")
	blast_count += 1
