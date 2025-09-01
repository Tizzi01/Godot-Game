extends Area2D
class_name MyHitBox

func _ready() -> void:
	monitoring = true
	set_deferred("monitoring", true)
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		print("✅ MyHitBox touched a HurtBox!")
