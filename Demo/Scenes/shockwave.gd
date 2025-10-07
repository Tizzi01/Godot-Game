extends Area2D

@export var slow_duration := 5.0
@export var slow_percent := 0.1
@export var push_force := 150.0

@onready var luffy: AudioStreamPlayer2D = $luffy
@onready var shockwave_timer: Timer = $ShockwaveTimer
@onready var cleanup_timer: Timer = $Timer
@onready var animation_sequence_timer: Timer = $AnimationSequenceTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var shock_timer: Timer = $ShockTimer
@onready var cooldown_bar: ProgressBar = $ShockwaveCooldownBar

# Animation control
var animation_play_count := 0
var animation_delays := [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.7]

# Shockwave control
var shockwave_count := 0
var blast_count := 0
const MAX_BLASTS := 4
const BLAST_INTERVAL := 0.3
const LIFETIME := 4.5

# Cooldown system
var is_on_cooldown := false
var cooldown_remaining := 0.0

func _ready():
	print("🚀 READY: Shockwave node initialized at", global_position)

	connect("body_entered", _on_body_entered)
	shockwave_timer.timeout.connect(_on_ShockwaveTimer_timeout)
	animation_sequence_timer.timeout.connect(_on_AnimationSequenceTimer_timeout)
	shock_timer.timeout.connect(_on_shockwave_cooldown_finished)

	luffy.play()
	animation_player.play("expand")
	animation_play_count = 1
	_schedule_next_animation()

	if not is_on_cooldown:
		trigger_screen_shockwave()

	shockwave_timer.wait_time = BLAST_INTERVAL
	shockwave_timer.start()

	cleanup_timer.wait_time = 7.0
	cleanup_timer.start()
	cleanup_timer.timeout.connect(queue_free)

func _schedule_next_animation():
	if animation_play_count < animation_delays.size():
		var delay = animation_delays[animation_play_count]
		animation_sequence_timer.one_shot = true
		animation_sequence_timer.wait_time = delay
		animation_sequence_timer.start()

func _on_AnimationSequenceTimer_timeout():
	animation_player.play("expand")
	animation_play_count += 1
	_schedule_next_animation()

func _on_ShockwaveTimer_timeout():
	shockwave_count += 1
	if shockwave_count < MAX_BLASTS and not is_on_cooldown:
		trigger_screen_shockwave()
	else:
		shockwave_timer.stop()

func _on_body_entered(body):
	if is_on_cooldown:
		print("🛑 Shockwave on cooldown —", int(cooldown_remaining), "s left")
		return

	if body.is_in_group("Mob") or body.is_in_group("Mob2"):
		var direction = (body.global_position - global_position).normalized()

		if body.has_method("apply_slowdown"):
			body.apply_slowdown(slow_duration, slow_percent)

		if body.has_method("apply_pushback"):
			body.apply_pushback(direction * push_force)

		trigger_screen_shockwave()

func trigger_screen_shockwave():
	if is_on_cooldown:
		print("🛑 Shockwave on cooldown —", int(cooldown_remaining), "s left")
		return

	print("🎬 Triggering screen shockwave")

	var layer = get_tree().get_root().get_node("Game/ShockwaveLayer")
	if layer == null: return

	var effect = layer.get_node("ShockwaveEffect")
	if effect == null: return

	var mat = effect.material
	if mat == null: return

	var screen_size = get_viewport().get_visible_rect().size
	var normalized_center = global_position / screen_size

	mat.set_shader_parameter("center", normalized_center)
	mat.set_shader_parameter("radius", 0.0)

	var animator = layer.get_node("ShockwaveAnimator")
	if animator == null: return

	animator.play("blast")
	blast_count += 1

	start_shockwave_cooldown(shock_timer.wait_time)

func start_shockwave_cooldown(duration: float):
	is_on_cooldown = true
	cooldown_remaining = duration
	cooldown_bar.visible = true
	cooldown_bar.max_value = 100
	cooldown_bar.value = 100

	shock_timer.wait_time = duration
	shock_timer.start()

	var tween := create_tween()
	tween.tween_property(cooldown_bar, "value", 0, duration) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN)

	# Start countdown print loop
	countdown_tick()

func countdown_tick():
	if cooldown_remaining > 0:
		print("⏳ Shockwave cooldown:", int(cooldown_remaining), "s remaining")
		cooldown_remaining -= 1
		await get_tree().create_timer(1.0).timeout
		countdown_tick()

func _on_shockwave_cooldown_finished():
	is_on_cooldown = false
	cooldown_bar.visible = false
	print("✅ Shockwave ready — press R to use")
