extends Node2D

@onready var player = $Player
@onready var game_over_screen = %"Game Over"
@onready var music: AudioStreamPlayer = $Music

func _ready():
	IntroMusic1.stop_IntroMusic()
	
	# Connect the player's health_depleted signal to trigger game over
	player.health_depleted.connect(_on_game_over)
	%Music.play() 
	
func spawn_mob():
	var new_mob = preload("res://Assets for the acual game/Scenes/mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

	# Connect the mob's 'died' signal to the player's kill handler
	new_mob.died.connect(player._on_mob_died)
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
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		game_over_screen.visible = not game_over_screen.visible
