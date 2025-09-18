extends Node2D

# 📢 Signals
signal game_over_triggered

# 🎮 Game References
@onready var player = $Player
@onready var game_over_screen = %"Game Over"
@onready var music: AudioStreamPlayer = $Music
@onready var path_follow = %PathFollow2D

# 💬 Dialog System
@onready var text_box_scene = preload("res://Demo/Scenes/text_box.tscn")
var text_box
var text_box_position: Vector2
var dialog_lines: Array[String]
var current_line_index: int = 0
var is_dialog_active = false
var can_advance_line = false

# 🧟 Mob Spawning
var mob2_spawn_block_time := 18.0
var mob_spawn_interval := 0.4
var mob2_spawn_interval := 5.0
var mob_spawn_timer := 0.0
var mob2_spawn_timer := 0.0
const MAX_SLIMES := 500
const MAX_MOB2 := 50
var allow_spawning := true

func _ready():
	randomize()
	IntroMusic1.stop_IntroMusic()
	player.health_depleted.connect(_on_game_over)
	game_over_screen.game_over_glitched.connect(_on_game_over_glitched)
	music.play()

	# 🗨️ Start dialog after short delay
	await get_tree().create_timer(1.0).timeout
	var screen_size = get_viewport().get_visible_rect().size
	var box_width = 400
	var margin = 32
	var position = Vector2(screen_size.x - box_width - margin, screen_size.y - 96)
	start_dialog(position, ["Incoming Threat: Space Slimes are launching an invasion"])

func _process(delta):
	if not allow_spawning:
		return

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

	var bus_index := AudioServer.get_bus_index("Master")
	for i in range(AudioServer.get_bus_effect_count(bus_index)):
		var effect := AudioServer.get_bus_effect(bus_index, i)
		if effect is AudioEffectReverb:
			AudioServer.remove_bus_effect(bus_index, i)
			break

	get_tree().reload_current_scene()
	

func _on_main_menu_pressed():
	print("🏠 Main Menu button pressed")

	# 🧼 Remove reverb effect from Master bus
	var bus_index := AudioServer.get_bus_index("Master")
	for i in range(AudioServer.get_bus_effect_count(bus_index)):
		var effect := AudioServer.get_bus_effect(bus_index, i)
		if effect is AudioEffectReverb:
			AudioServer.remove_bus_effect(bus_index, i)
			break

	get_tree().change_scene_to_file("res://Folder/Scenes/main_menu.tscn")

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		game_over_screen.visible = not game_over_screen.visible

# 💬 Dialog System
func start_dialog(position: Vector2, lines: Array[String]):
	if is_dialog_active:
		print("Dialog already active. Skipping.")
		return

	print("🟢 Starting dialog with lines:", lines)
	dialog_lines = lines
	current_line_index = 0
	text_box_position = position
	_show_text_box()
	is_dialog_active = true

func _show_text_box():
	print("📦 Instantiating text box...")
	text_box = text_box_scene.instantiate()

	var ui_layer = get_tree().current_scene.get_node("CanvasLayer3")
	if ui_layer:
		ui_layer.add_child(text_box)
	else:
		print("❌ CanvasLayer3 not found in current scene!")
		return

	text_box.position = text_box_position
	text_box.visible = true
	text_box.modulate.a = 1.0

	print("📝 Calling display_text with:", dialog_lines[current_line_index])
	text_box.display_text(dialog_lines[current_line_index])
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	can_advance_line = false

func _on_text_box_finished_displaying():
	print("⏳ Text finished displaying. Starting fade out...")
	await get_tree().create_timer(3.0).timeout

	var tween = create_tween()
	tween.tween_property(text_box, "modulate:a", 0.0, 1.0)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	await tween.finished
	text_box.queue_free()
	is_dialog_active = false
	current_line_index = 0
	print("✅ Text box removed. Dialog reset.")

# 🔊 Music Fade-Out
func fade_out_music(duration := 5.0):
	var bus_index := AudioServer.get_bus_index("Master")
	if AudioServer.get_bus_effect_count(bus_index) == 0:
		var reverb := AudioEffectReverb.new()
		reverb.room_size = 0.8
		reverb.damping = 0.3
		reverb.wet = 0.6
		reverb.dry = 0.4
		AudioServer.add_bus_effect(bus_index, reverb, 0)

	var start_volume := music.volume_db
	var end_volume := -80.0
	var time_passed := 0.0

	while time_passed < duration:
		var t := time_passed / duration
		music.volume_db = lerp(start_volume, end_volume, t)
		await get_tree().create_timer(0.05).timeout
		time_passed += 0.05

	music.volume_db = end_volume 
