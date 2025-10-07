extends Area2D

@export var slow_duration := 5.0
@export var slow_percent := 0.1
@export var push_force := 150.0

@onready var luffy: AudioStreamPlayer2D = $luffy
@onready var cleanup_timer: Timer = $Timer
@onready var animation_sequence_timer: Timer = $AnimationSequenceTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var out: AudioStreamPlayer = $out

# Animation control
var animation_play_count := 0
var animation_delays := [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]

# Shockwave control
var blast_count := 0

func _ready():
	print("🚀 READY: Shockwave node initialized at", global_position)

	connect("body_entered", _on_body_entered)
	animation_sequence_timer.timeout.connect(_on_AnimationSequenceTimer_timeout)

	print("🎧 Playing luffy sound")
	luffy.play()

	print("🎞️ Starting animation sequence")
	animation_player.play("expand")
	animation_play_count = 1
	_schedule_next_animation()

	print("💥 Triggering initial shockwave")
	trigger_screen_shockwave()

	cleanup_timer.wait_time = 9.0
	cleanup_timer.start()
	cleanup_timer.timeout.connect(queue_free)
	print("🧹 Cleanup timer set for 9 seconds")

func _schedule_next_animation():
	if animation_play_count < animation_delays.size():
		var delay = animation_delays[animation_play_count]
		print("⏳ Scheduling next animation in", delay, "seconds")
		animation_sequence_timer.one_shot = true
		animation_sequence_timer.wait_time = delay
		animation_sequence_timer.start()

func _on_AnimationSequenceTimer_timeout():
	print("🎞️ Animation sequence tick", animation_play_count)
	animation_player.play("expand")
	animation_play_count += 1
	_schedule_next_animation()
	trigger_screen_shockwave()

func _on_body_entered(body):
	print("👾 Body entered:", body.name)
	if body.is_in_group("Mob") or body.is_in_group("Mob2"):
		var direction = (body.global_position - global_position).normalized()

		if body.has_method("apply_slowdown"):
			print("🐌 Applying slowdown to", body.name)
			body.apply_slowdown(slow_duration, slow_percent)

		if body.has_method("apply_pushback"):
			print("💨 Applying pushback to", body.name)
			body.apply_pushback(direction * push_force)

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
		print("❌ ShockwaveEffect material missing")
		return

	var screen_size = get_viewport().get_visible_rect().size
	var normalized_center = global_position / screen_size

	mat.set_shader_parameter("center", normalized_center)
	mat.set_shader_parameter("radius", 0.0)

	var animator = layer.get_node("ShockwaveAnimator")
	if animator == null:
		print("❌ ShockwaveAnimator not found")
		return

	animator.play("blast")
	blast_count += 1
	print("💥 Blast", blast_count, "animation played")

	if out:
		print("🔊 Attempting to play OUT sound")
		out.stop()
		out.play()
	else:
		print("❌ OUT sound node is null")

func _play_out_sound():
	if out:
		out.stop()
		out.volume_db = -20
		out.play()
