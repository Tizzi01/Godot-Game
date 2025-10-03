extends Area2D

@export var slow_duration := 5.0
@export var slow_percent := 0.1
@export var push_force := 150.0

func _ready():
	print("🚀 Shockwave spawned at:", global_position)
	$AnimationPlayer.play("expand")
	connect("body_entered", _on_body_entered)
	$Timer.timeout.connect(queue_free)

func _on_body_entered(body):
	print("💥 Shockwave touched:", body.name)

	if body.is_in_group("Mob") or body.is_in_group("Mob2"):
		var direction = (body.global_position - global_position).normalized()

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
	print("📍 Normalized center:", normalized_center)

	mat.set_shader_parameter("center", normalized_center)
	mat.set_shader_parameter("radius", 0.0)

	var animator = layer.get_node("ShockwaveAnimator")
	if animator == null:
		print("❌ ShockwaveAnimator not found")
		return

	print("🎞️ Playing shockwave_blast animation")
	animator.play("shockwave_blast")
