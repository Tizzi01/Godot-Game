extends Area2D

@onready var anim = $AnimationPlayer

func _ready():
	print("⚡ Power bullet ready — starting shockwave")
	monitoring = true  # ✅ Enable collision detection
	anim.play("shockwave")

	connect("body_entered", Callable(self, "_on_body_entered"))
	anim.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_body_entered(body):
	print("🔥 Power bullet collided with:", body.name)
	if body.has_method("take_damage"):
		print("💢 Applying damage to:", body.name)
		body.take_damage()

func _on_animation_finished(anim_name):
	if anim_name == "shockwave":
		print("🧼 Shockwave finished — cleaning up Power bullet")
		queue_free()
