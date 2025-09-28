extends Area2D

@onready var anim = $AnimationPlayer
@onready var lifetime_timer = $LifetimeTimer
@onready var pull_zone = $PullZone

var affected_bodies: Array = []

func _ready():
	print("⚡ Power bullet ready — starting shockwave")
	monitoring = true
	anim.play("shockwave")

	# Damage zone (Power node)
	connect("body_entered", Callable(self, "_on_damage_zone_entered"))

	# Pull zone (child Area2D)
	pull_zone.connect("body_entered", Callable(self, "_on_pull_zone_entered"))
	pull_zone.connect("body_exited", Callable(self, "_on_pull_zone_exited"))

	# Timer cleanup
	lifetime_timer.timeout.connect(_on_lifetime_timeout)

func _on_damage_zone_entered(body):
	if body is CharacterBody2D:
		print("💥 CharacterBody2D touched center — applying damage:", body.name)
		if body.has_method("take_damage"):
			body.take_damage()

func _on_pull_zone_entered(body):
	print("📡 PullZone detected:", body.name)
	if body is CharacterBody2D:
		print("🌀 CharacterBody2D entered pull zone:", body.name)
		affected_bodies.append(body)

func _on_pull_zone_exited(body):
	print("📡 PullZone exit detected:", body.name)
	if body is CharacterBody2D:
		print("🚪 CharacterBody2D exited pull zone:", body.name)
		affected_bodies.erase(body)

func _physics_process(delta):
	for body in affected_bodies:
		if body and body.is_inside_tree():
			var direction = (global_position - body.global_position).normalized()
			print("🧲 Suction applied to:", body.name, "→", direction)
			body.velocity += direction * 5888 * delta  # Adjust suction strength

func _on_lifetime_timeout():
	print("🕒 Black hole lifetime ended — cleaning up")
	queue_free()
