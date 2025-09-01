extends Node2D
class_name Enemy

@export var max_health: int = 250
var current_health: int

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	current_health = max_health
	var hurtbox = $MyHurtBox
	if hurtbox:
		hurtbox.enemy = self

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Enemy took", amount, "damage. HP:", current_health)
	animation_player.play("hit1")
	if current_health <= 0:
		die()

func die() -> void:
	print("💀 Enemy died")
	if animation_player.has_animation("death"):
		animation_player.play("death")
		await animation_player.animation_finished
	queue_free()


func _on_my_hurt_box_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
