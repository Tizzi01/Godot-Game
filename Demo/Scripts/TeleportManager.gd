extends Node

var can_teleport := true

func start_cooldown():
	can_teleport = false
	var delay = randf_range(2.0, 5.0)
	await get_tree().create_timer(delay).timeout
	can_teleport = true
