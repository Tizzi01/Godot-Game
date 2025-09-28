extends Area2D

@onready var omni: AudioStreamPlayer = $Omni
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var up: AudioStreamPlayer = $up
@onready var cooldown_timer: Timer = $BlackHoleCooldownTimer
@onready var cooldown_bar: ProgressBar = get_node("/root/Game/CanvasLayer3/BHCD")

var hold_timer := 0.0
var hold_threshold := 1.5
var has_spawned := false
var black_hole_ready := true

func _ready():
	cooldown_timer.timeout.connect(_on_black_hole_cooldown_finished)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("slash"):
		hold_timer += delta

		if animation_player and animation_player.current_animation != "charge":
			animation_player.play("charge")
			up.play()

		if hold_timer >= hold_threshold and not has_spawned and black_hole_ready:
			spawn_black_hole()
			has_spawned = true
			black_hole_ready = false
			cooldown_timer.start()

			# 🔄 Start cooldown bar animation
			cooldown_bar.visible = true
			cooldown_bar.max_value = 100
			cooldown_bar.value = 100

			var tween := create_tween()
			tween.tween_property(cooldown_bar, "value", 0, cooldown_timer.wait_time) \
				.set_trans(Tween.TRANS_CUBIC) \
				.set_ease(Tween.EASE_IN)
	else:
		# Let charge animation fade naturally
		pass

	if Input.is_action_just_released("slash"):
		hold_timer = 0.0
		has_spawned = false

func spawn_black_hole():
	var power = preload("res://Demo/Scenes/power.tscn").instantiate()
	power.global_position = get_global_mouse_position()
	get_tree().current_scene.add_child(power)
	power.add_to_group("black")

	var camera = get_tree().get_root().get_node("Game/Player/Camera2D")
	if camera and power.has_signal("black_hole_spawned"):
		power.black_hole_spawned.connect(Callable(camera, "_on_black_hole_spawned"))

	print("🌌 Black hole spawned — cooldown started")

func _on_black_hole_cooldown_finished():
	black_hole_ready = true
	cooldown_bar.visible = false
	print("✅ Black hole cooldown finished")

func play_change_animation():
	var anim = get_node_or_null("AnimationPlayer")
	if anim:
		anim.play("change")

	if omni:
		omni.play()
