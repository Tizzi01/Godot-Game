extends Node2D



func spawn_mob(): 
	var new_mob = preload("res://Assets for the acual game/Scenes/mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position 
	add_child(new_mob)


func _on_timer_timeout() -> void:
	spawn_mob() 
