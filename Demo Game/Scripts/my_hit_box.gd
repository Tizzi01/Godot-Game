class_name MyHitBox
extends Area2D

@export var damage := 10

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	print("Hitbox touched: ", area.name)
	if area.has_method("take_damage"):
		area.take_damage(damage) 
