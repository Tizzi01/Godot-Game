extends Node2D

@onready var player = $Player
@onready var game_over_screen = %"Game Over"

func _ready():
	# Connect the player's health_depleted signal to trigger game over
	player.health_depleted.connect(_on_game_over)

func spawn_mob():
	var new_mob = preload("res://Assets for the acual game/Scenes/mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

func _on_timer_timeout() -> void:
	spawn_mob()

func _on_game_over():
	game_over_screen.show()

func _on_restart_pressed():
	print("🔁 Restart button pressed")
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	print("🏠 Main Menu button pressed")
	get_tree().change_scene_to_file("res://Assets for the acual game/Scenes/main_menu.tscn")
