extends Node2D

signal game_over_triggered  # ✅ Signal to notify timer and others

@onready var player = $Player
@onready var game_over_screen = %"Game Over"
@onready var music: AudioStreamPlayer = $Music
@onready var path_follow = %PathFollow2D

var mob2_spawn_block_time := 18.0
var mob_spawn_interval := 0.4
var mob2_spawn_interval := 5.0

var mob_spawn_timer := 0.0
var mob2_spawn_timer := 0.0

const MAX_SLIMES := 500
const MAX_MOB2 := 50

var allow_spawning := true  # ✅ New flag to control mob spawning

func _ready():
	randomize()
	IntroMusic1.stop_IntroMusic()
	player.health_depleted.connect(_on_game_over)
	game_over_screen.game_over_glitched.connect(_on_game_over_glitched)
	music.play()

func _process(delta):
	if not allow_spawning:
		return  # ✅ Skip all spawning logic if game is over

	mob_spawn_timer += delta
	mob2_spawn_timer += delta

	if mob_spawn_timer >= mob_spawn_interval:
		mob_spawn_timer = 0.0
		if get_tree().get_nodes_in_group("Mob").size() < MAX_SLIMES:
			spawn_mob()

	if mob2_spawn_block_time > 0.0:
		mob2_spawn_block_time -= delta
	else:
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
	game_over_screen.trigger_game_over()
	allow_spawning = false
	emit_signal("game_over_triggered")
	fade_out_music()

func _on_game_over_glitched():
	allow_spawning = false
	emit_signal("game_over_triggered")

func _on_restart_pressed():
	AnimeShine.play_ClickSound()
	print("🔁 Restart button pressed")

	# 🧼 Remove reverb effect from Master bus
	var bus_index := AudioServer.get_bus_index("Master")
	for i in range(AudioServer.get_bus_effect_count(bus_index)):
		var effect := AudioServer.get_bus_effect(bus_index, i)
		if effect is AudioEffectReverb:
			AudioServer.remove_bus_effect(bus_index, i)
			break  # Remove only one instance

	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	print("🏠 Main Menu button pressed")
	get_tree().change_scene_to_file("res://Folder/Scenes/main_menu.tscn")

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		game_over_screen.visible = not game_over_screen.visible


func fade_out_music(duration := 5.0):
	# Add reverb effect if not already present
	var bus_index := AudioServer.get_bus_index("Master")
	if AudioServer.get_bus_effect_count(bus_index) == 0:
		var reverb := AudioEffectReverb.new()
		reverb.room_size = 0.8
		reverb.damping = 0.3
		reverb.wet = 0.6
		reverb.dry = 0.4
		AudioServer.add_bus_effect(bus_index, reverb, 0)

	# Fade out volume over time
	var start_volume := music.volume_db
	var end_volume := -80.0
	var time_passed := 0.0

	while time_passed < duration:
		var t := time_passed / duration
		music.volume_db = lerp(start_volume, end_volume, t)
		await get_tree().create_timer(0.05).timeout
		time_passed += 0.05

	music.volume_db = end_volume
