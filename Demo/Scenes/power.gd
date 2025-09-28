extends Area2D

signal black_hole_spawned  # 📢 Signal for camera shake

@onready var anim = $AnimationPlayer
@onready var pull_zone = $PullZone
@onready var idle: AudioStreamPlayer2D = $Idle
@onready var ka: AudioStreamPlayer = $ka
@onready var pf: AudioStreamPlayer = $PF
@onready var timer_10s: Timer = $J  # ⏱️ Reference to the Timer node

var min_audio_distance: float = 0.0
var max_audio_distance: float = 888.0

var affected_mobs: Array = []
var affected_player: CharacterBody2D = null

func _ready():
	add_to_group("black")
	idle.finished.connect(_on_idle_finished)
	ka.play()
	idle.play()
	_update_idle_volume()
	monitoring = true
	anim.play("shockwave")

	call_deferred("emit_black_hole_signal")

	connect("body_entered", Callable(self, "_on_damage_zone_entered"))
	pull_zone.connect("body_entered", Callable(self, "_on_pull_zone_entered"))
	pull_zone.connect("body_exited", Callable(self, "_on_pull_zone_exited"))

	# 🔧 Start the timer and connect its timeout
	timer_10s.timeout.connect(_on_10s_timeout)
	timer_10s.start()

func emit_black_hole_signal():
	emit_signal("black_hole_spawned")
	print("📢 Signal emitted: black_hole_spawned")

func _on_damage_zone_entered(body):
	if body.is_in_group("Mob") and body.has_method("take_damage"):
		body.take_damage(10)
	elif body.is_in_group("Mob2") and body.has_method("take_damage"):
		body.take_damage(30, "blackhole")
	elif body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(10)

func _on_pull_zone_entered(body):
	if body.is_in_group("Mob") or body.is_in_group("Mob2"):
		body.is_being_pulled = true
		affected_mobs.append(body)
	elif body.is_in_group("player"):
		affected_player = body

func _on_pull_zone_exited(body):
	if body.is_in_group("Mob") or body.is_in_group("Mob2"):
		body.is_being_pulled = false
		affected_mobs.erase(body)
	elif body.is_in_group("player"):
		affected_player = null

func _physics_process(delta: float) -> void:
	var max_range: float = 500.0

	for mob in affected_mobs:
		if mob and mob.is_inside_tree():
			var direction = (global_position - mob.global_position).normalized()
			var distance = global_position.distance_to(mob.global_position)
			var t = clamp(1.0 - (distance / max_range), 0.0, 1.0)
			var suction_strength = lerp(10000.0, 20000.0, pow(t, 2.5))
			mob.velocity += direction * suction_strength * delta

	if affected_player and affected_player.is_inside_tree():
		var direction = (global_position - affected_player.global_position).normalized()
		var distance = global_position.distance_to(affected_player.global_position)
		var t = clamp(1.0 - (distance / max_range), 0.0, 1.0)
		var suction_strength = lerp(10000.0, 20000.0, pow(t, 2.5)) * 0.1
		affected_player.velocity += direction * suction_strength * delta

	_update_idle_volume()

func _update_idle_volume():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		if player and player.is_inside_tree():
			var distance = global_position.distance_to(player.global_position)
			var audio_t = clamp(1.0 - ((distance - min_audio_distance) / (max_audio_distance - min_audio_distance)), 0.0, 1.0)
			idle.volume_db = lerp(-40.0, 15.0, audio_t)
			return
	idle.volume_db = -40.0 
	
func _on_idle_finished():
	idle.play()

func _on_10s_timeout():
	anim.play("close")
	pf.play()

	# Wait for animation and sound to finish before freeing
	await anim.animation_finished
	await pf.finished
	queue_free()
