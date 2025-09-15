extends Node2D

@onready var player = $Player
@onready var game_over_screen = %"Game Over"
@onready var music: AudioStreamPlayer = $Music
@onready var path_follow := %PathFollow2D

var mob_spawn_interval := 0.4
var mob2_spawn_interval := 5.0

var mob_spawn_timer := 0.0
var mob2_spawn_timer := 0.0

const MAX_SLIMES := 500
const MAX_MOB2 := 50

func _ready():
	randomize()
	IntroMusic1.stop_IntroMusic()
	player.health_depleted.connect(_on_game_over)
	music.play()

func _process(delta):
	mob_spawn_timer += delta
	mob2_spawn_timer += delta

	if mob_spawn_timer >= mob_spawn_interval:
		mob_spawn_timer = 0.0
		if get_tree().get_nodes_in_group("Mob").size() < MAX_SLIMES:
			spawn_mob()

	if mob2_spawn_timer >= mob2_spawn_interval:
		mob2_spawn_timer = 0.0
		if get_tree().get_nodes_in_group("Mob2").size() < MAX_MOB2:
			spawn_mob2()

func spawn_mob():
	var new_mob = preload("res://Folder/Scenes/mob.tscn").instantiate()
	path_follow.progress_ratio = randf()
	new_mob.global_position = path_follow.global_position
	add_child(new_mob)
	new_mob.add_to_group("Mob")
	new_mob.died.connect(player._on_mob_died)

func spawn_mob2():
	var new_mob2 = preload("res://Folder/Scenes/mob2.tscn").instantiate()
	path_follow.progress_ratio = randf()
	new_mob2.global_position = path_follow.global_position
	add_child(new_mob2)
	new_mob2.add_to_group("Mob2")
	new_mob2.died.connect(player._on_mob_died)

	print("🚀 Spawned Mob2 with speed:", new_mob2.move_speed, "and health:", new_mob2.health)

func _on_game_over():
	game_over_screen.show()
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
