class_name MyHurtBox
extends Area2D

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	# Use Callable instead of string for safer signal connection
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	if area is MyHitBox:
		var hitbox := area as MyHitBox
		if owner and owner.has_method("take_damage"):
			owner.take_damage(hitbox.damage) 
