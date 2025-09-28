extends Area2D

@onready var anim = $AnimationPlayer
@onready var lifetime_timer = $LifetimeTimer
@onready var pull_zone = $PullZone

var affected_mobs: Array = []
var affected_player: CharacterBody2D = null

func _ready():
	print("⚡ Power bullet ready — starting shockwave")
	monitoring = true
	anim.play("shockwave")

	# Connect damage zone
	connect("body_entered", Callable(self, "_on_damage_zone_entered"))

	# Connect pull zone
	pull_zone.connect("body_entered", Callable(self, "_on_pull_zone_entered"))
	pull_zone.connect("body_exited", Callable(self, "_on_pull_zone_exited"))

	# Cleanup timer
	lifetime_timer.timeout.connect(_on_lifetime_timeout)

func _on_damage_zone_entered(body):
	print("📡 Damage zone detected:", body.name)

	if body.is_in_group("Mob"):
		print("💥 Mob touched center — applying damage")
		if body.has_method("take_damage"):
			body.take_damage(10)

	elif body.is_in_group("Mob2"):
		if body.has_method("take_damage"):
			body.take_damage(30, "blackhole")

	elif body.is_in_group("player"):
		print("💥 Player touched black hole core — applying damage")
		if body.has_method("take_damage"):
			body.take_damage(10)

func _on_pull_zone_entered(body):
	print("📡 PullZone detected:", body.name)

	if body.is_in_group("Mob") or body.is_in_group("Mob2"):
		print("🌀 Mob or Mob2 entered pull zone")
		body.is_being_pulled = true
		affected_mobs.append(body)

	elif body.is_in_group("player"):
		print("🌀 Player entered pull zone")
		affected_player = body

func _on_pull_zone_exited(body):
	print("📡 PullZone exit detected:", body.name)

	if body.is_in_group("Mob") or body.is_in_group("Mob2"):
		print("🚪 Mob or Mob2 exited pull zone")
		body.is_being_pulled = false
		affected_mobs.erase(body)

	elif body.is_in_group("player"):
		print("🚪 Player exited pull zone")
		affected_player = null

func _physics_process(delta: float) -> void:
	var max_range: float = 500.0

	for mob in affected_mobs:
		if mob and mob.is_inside_tree():
			var direction = (global_position - mob.global_position).normalized()
			var distance = global_position.distance_to(mob.global_position)
			var t = clamp(1.0 - (distance / max_range), 0.0, 1.0)
			var suction_strength = lerp(10000.0, 20000.0, pow(t, 2.5))

			print("🧲 Suction applied to mob:", mob.name, "| Strength:", suction_strength)
			mob.velocity += direction * suction_strength * delta

	if affected_player and affected_player.is_inside_tree():
		var direction = (global_position - affected_player.global_position).normalized()
		var distance = global_position.distance_to(affected_player.global_position)
		var t = clamp(1.0 - (distance / max_range), 0.0, 1.0)
		var suction_strength = lerp(10000.0, 20000.0, pow(t, 2.5)) * 0.10
		print("🧲 Suction applied to player | Strength:", suction_strength)
		affected_player.velocity += direction * suction_strength * delta

func _on_lifetime_timeout():
	print("🕒 Black hole lifetime ended — cleaning up")
	queue_free()
