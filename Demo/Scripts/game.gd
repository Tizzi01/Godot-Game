extends Node2D

@onready var player = $Player
@onready var game_over_screen = %"Game Over"
@onready var music: AudioStreamPlayer = $Music
@onready var path_follow := %PathFollow2D

# Spawn rate control
var mob_spawn_interval := 1.0      # seconds between mob spawns
var mob2_spawn_interval := 3.0     # seconds between mob2 spawns

var mob_spawn_timer := 0.0
var mob2_spawn_timer := 0.0

func _ready():
	IntroMusic1.stop_IntroMusic()
	player.health_depleted.connect(_on_game_over)
	music.play()

func _process(delta):
	# Update timers
	mob_spawn_timer += delta
	mob2_spawn_timer += delta

	# Spawn mob
	if mob_spawn_timer >= mob_spawn_interval:
		mob_spawn_timer = 0.0
		spawn_mob()

	# Spawn mob2
	if mob2_spawn_timer >= mob2_spawn_interval:
		mob2_spawn_timer = 0.0
		spawn_mob2()

func spawn_mob():
	var new_mob = preload("res://Folder/Scenes/mob.tscn").instantiate()
	path_follow.progress_ratio = randf()
	new_mob.global_position = path_follow.global_position
	add_child(new_mob)
	new_mob.died.connect(player._on_mob_died)

func spawn_mob2():
	var new_mob2 = preload("res://Folder/Scenes/mob2.tscn").instantiate()
	path_follow.progress_ratio = randf()
	new_mob2.global_position = path_follow.global_position
	add_child(new_mob2)
	new_mob2.died.connect(player._on_mob_died)

func _on_game_over():
	game_over_screen.show()
	# Stop spawning by setting intervals to a high value
	mob_spawn_interval = 9999
	mob2_spawn_interval = 9999

func _on_restart_pressed():
	AnimeShine.play_ClickSound()
	print("🔁 Restart button pressed")
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	print("🏠 Main Menu button pressed")
	get_tree().change_scene_to_file("res://Folder/Scenes/main_menu.tscn")

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		game_over_screen.visible = not game_over_screen.visible
