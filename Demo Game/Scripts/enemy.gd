extends Node2D

@onready var animation_player := $AnimationPlayer 

func take_damage(amoung: int) -> void: 
	animation_player.play("hit1") 
