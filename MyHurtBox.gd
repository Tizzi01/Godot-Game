extends Area2D
class_name HurtBox

func _ready() -> void:
	add_to_group("hurtbox")
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	if area is MyHitBox:
		print("💥 HurtBox touched a MyHitBox!")
