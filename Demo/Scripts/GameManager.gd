extends Node

# 🌟 GameManager: Central brain of the game

# === GAME STATE ===
var is_game_running := false
var is_game_paused := false
var current_level := 0
var player_score := 0
var player_lives := 3
var max_lives := 3
var game_time := 0.0

# === PLAYER TRACKING ===
var player_node: Node = null
var player_position := Vector2.ZERO
var player_health := 100

# === SETTINGS / SAVE DATA ===
var settings := {
	"music_volume": 0.8,
	"sfx_volume": 0.8,
	"difficulty": "normal"
}
var save_data := {}

# === SIGNALS ===
signal game_started
signal game_paused
signal game_resumed
signal game_over
signal level_changed(new_level)
signal score_updated(new_score)
signal lives_updated(new_lives)
signal player_health_updated(new_health)

# === READY ===
func _ready() -> void:
	print("🧠 GameManager initialized.")
	reset_game_state()

# === GAME FLOW ===
func start_game() -> void:
	print("🎮 Game starting...")
	is_game_running = true
	is_game_paused = false
	current_level = 1
	player_score = 0
	player_lives = max_lives
	game_time = 0.0
	emit_signal("game_started")
	print("✅ Game started. Level:", current_level)

func pause_game() -> void:
	if is_game_running and not is_game_paused:
		is_game_paused = true
		emit_signal("game_paused")
		print("⏸️ Game paused.")

func resume_game() -> void:
	if is_game_running and is_game_paused:
		is_game_paused = false
		emit_signal("game_resumed")
		print("▶️ Game resumed.")

func end_game() -> void:
	print("💀 Game over triggered.")
	is_game_running = false
	is_game_paused = false
	emit_signal("game_over")
	save_game()

func reset_game_state() -> void:
	print("🔄 Resetting game state...")
	is_game_running = false
	is_game_paused = false
	current_level = 0
	player_score = 0
	player_lives = max_lives
	game_time = 0.0
	player_health = 100
	player_position = Vector2.ZERO
	player_node = null

# === LEVEL MANAGEMENT ===
func change_level(new_level: int) -> void:
	print("🔁 Changing level from", current_level, "to", new_level)
	current_level = new_level
	emit_signal("level_changed", new_level)

# === SCORE / LIVES ===
func add_score(points: int) -> void:
	player_score += points
	print("🏆 Score increased by", points, "| Total:", player_score)
	emit_signal("score_updated", player_score)

func lose_life() -> void:
	player_lives -= 1
	print("💔 Lost a life. Remaining:", player_lives)
	emit_signal("lives_updated", player_lives)
	if player_lives <= 0:
		end_game()

func gain_life() -> void:
	if player_lives < max_lives:
		player_lives += 1
		print("💖 Gained a life. Total:", player_lives)
		emit_signal("lives_updated", player_lives)

# === PLAYER ===
func register_player(player: Node) -> void:
	player_node = player
	print("🧍 Player registered:", player.name)

func update_player_position(pos: Vector2) -> void:
	player_position = pos
	print("📍 Player position updated:", pos)

func update_player_health(amount: int) -> void:
	player_health = clamp(amount, 0, 100)
	print("❤️ Player health updated:", player_health)
	emit_signal("player_health_updated", player_health)
	if player_health <= 0:
		print("☠️ Player died.")
		lose_life()

# === SETTINGS ===
func set_setting(key: String, value) -> void:
	if settings.has(key):
		settings[key] = value
		print("⚙️ Setting updated:", key, "→", value)
	else:
		print("❓ Unknown setting:", key)

func get_setting(key: String):
	if settings.has(key):
		return settings[key]
	return null

# === SAVE / LOAD ===
func save_game() -> void:
	print("💾 Saving game...")
	save_data = {
		"level": current_level,
		"score": player_score,
		"lives": player_lives,
		"settings": settings
	}
	print("📦 Save data:", save_data)

func load_game() -> void:
	print("📂 Loading game...")
	if save_data.size() == 0:
		print("❌ No save data found.")
		return
	current_level = save_data.get("level", 1)
	player_score = save_data.get("score", 0)
	player_lives = save_data.get("lives", max_lives)
	settings = save_data.get("settings", settings)
	print("✅ Game loaded. Level:", current_level, "| Score:", player_score, "| Lives:", player_lives)

# === DEBUG UTILITIES ===
func print_status() -> void:
	print("📊 Game Status:")
	print("  Running:", is_game_running)
	print("  Paused:", is_game_paused)
	print("  Level:", current_level)
	print("  Score:", player_score)
	print("  Lives:", player_lives)
	print("  Health:", player_health)
	print("  Position:", player_position)
	print("  Settings:", settings)

func simulate_tick(delta: float) -> void:
	if is_game_running and not is_game_paused:
		game_time += delta
		print("⏱️ Game time:", game_time)

# === TESTING HOOKS ===
func debug_add_score() -> void:
	add_score(100)

func debug_lose_life() -> void:
	lose_life()

func debug_gain_life() -> void:
	gain_life()

func debug_change_level() -> void:
	change_level(current_level + 1)

func debug_reset() -> void:
	reset_game_state()
	print("🧹 Game state reset.")

func debug_toggle_pause() -> void:
	if is_game_paused:
		resume_game()
	else:
		pause_game() 
		
		
# === MOBX POWER FUNCTIONS ===

func power_teleport_mobs() -> void:
	print("🌀 Power: Teleporting all Mobx members randomly!")
	for mob in get_tree().get_nodes_in_group("Mobx"):
		var new_pos := Vector2(randf() * 1000, randf() * 600)
		mob.global_position = new_pos
		print("📍", mob.name, "teleported to", new_pos)

func power_speed_up_mobs() -> void:
	print("⚡ Power: Speeding up all Mobx members!")
	for mob in get_tree().get_nodes_in_group("Mobx"):
		if mob.has_method("set_speed"):
			mob.set_speed(mob.get_speed() * 2)
			print("🚀", mob.name, "speed doubled!")

func power_slow_down_mobs() -> void:
	print("🐌 Power: Slowing down all Mobx members!")
	for mob in get_tree().get_nodes_in_group("Mobx"):
		if mob.has_method("set_speed"):
			mob.set_speed(mob.get_speed() * 0.5)
			print("⛔", mob.name, "speed halved!")

func power_dash_mobs() -> void:
	print("💨 Power: Dashing all Mobx members forward!")
	for mob in get_tree().get_nodes_in_group("Mobx"):
		if mob.has_method("apply_impulse"):
			mob.apply_impulse(Vector2(300, 0))
			print("🏃", mob.name, "dashed forward!")

func power_dodge_bullets() -> void:
	print("🕶️ Power: Bullet dodging mode activated for Mobx!")
	for mob in get_tree().get_nodes_in_group("Mobx"):
		if mob.has_method("enable_dodge"):
			mob.enable_dodge(true)
			print("🛡️", mob.name, "can now dodge bullets!")

func power_invisibility_mobs() -> void:
	print("👻 Power: Turning Mobx invisible!")
	for mob in get_tree().get_nodes_in_group("Mobx"):
		mob.modulate.a = 0.2
		print("🙈", mob.name, "is now semi-invisible!")

func power_gravity_flip_mobs() -> void:
	print("🔄 Power: Flipping gravity for Mobx!")
	for mob in get_tree().get_nodes_in_group("Mobx"):
		if mob.has_method("set_gravity_scale"):
			mob.set_gravity_scale(-mob.get_gravity_scale())
			print("🌌", mob.name, "gravity flipped!")

func power_shield_mobs() -> void:
	print("🛡️ Power: Giving Mobx temporary shields!")
	for mob in get_tree().get_nodes_in_group("Mobx"):
		if mob.has_method("activate_shield"):
			mob.activate_shield(5.0)
			print("🔰", mob.name, "shield activated for 5 seconds!")

func power_clone_mobs() -> void:
	print("🧬 Power: Cloning all Mobx members!")
	for mob in get_tree().get_nodes_in_group("Mobx"):
		var clone := mob.duplicate()
		get_parent().add_child(clone)
		clone.global_position += Vector2(50, 0)
		print("👯", mob.name, "cloned!")

func power_freeze_time_mobs() -> void:
	print("🕰️ Power: Freezing Mobx in time!")
	for mob in get_tree().get_nodes_in_group("Mobx"):
		if mob.has_method("set_process"):
			mob.set_process(false)
			print("❄️", mob.name, "frozen in time!")
