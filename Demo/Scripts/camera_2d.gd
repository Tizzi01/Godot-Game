extends Camera2D

@export var decay : float = 1.2
@export var max_offset : Vector2 = Vector2(10, 6)
@export var max_roll : float = 0.01
@export var follow_node : Node2D
@onready var animation_player: AnimationPlayer = $"../../CanvasLayer4/Panel/AnimationPlayer"

var trauma : float = 0.0
var trauma_power : int = 1
var shake_on_cooldown := false

func _ready() -> void:
	randomize()
	startup_zoom_and_shake()
	print("📸 Camera ready — initializing")

	var player := get_parent()
	if player:
		print("👤 Found player node:", player.name)
		if player.has_signal("player_damaged"):
			player.player_damaged.connect(_on_player_damaged)
			print("📸 Connected to player_damaged signal")
		else:
			print("⚠️ Player has no 'player_damaged' signal")
	else:
		print("🚫 Player node not found")

	# 🔗 Connect to black holes in "black" group
	var black_holes = get_tree().get_nodes_in_group("black")
	print("🔍 Found", black_holes.size(), "nodes in group 'black'")
	for black_hole in black_holes:
		print("🔎 Checking node:", black_hole.name)
		if black_hole.has_signal("black_hole_spawned"):
			var result = black_hole.black_hole_spawned.connect(Callable(self, "_on_black_hole_spawned"))
			if result == OK:
				print("✅ Connected to black hole signal:", black_hole.name)
			else:
				print("❌ Failed to connect to black hole signal:", black_hole.name)
		else:
			print("⚠️ Signal 'black_hole_spawned' missing on:", black_hole.name)

func _process(delta: float) -> void:
	if follow_node:
		global_position = follow_node.global_position

	if trauma > 0.0:
		print("📸 Trauma active:", trauma)
		trauma = max(trauma - decay * delta, 0.0)
		shake()

func add_trauma(amount : float) -> void:
	print("💢 Adding trauma:", amount)
	trauma = min(trauma + amount, 1.0)

func add_vertical_trauma(amount: float) -> void:
	print("💢 Adding vertical trauma:", amount)
	trauma = min(trauma + amount, 1.0)
	offset.x = 0
	rotation = 0

func add_glitch_trauma(amount: float) -> void:
	print("💢 Adding glitch trauma:", amount)
	trauma = min(trauma + amount, 1.0)

func shake() -> void:
	var amount = pow(trauma, trauma_power)
	print("🌪️ Shake amount:", amount)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)

func _on_item_acquired():
	add_trauma(0.3)

func startup_zoom_and_shake():
	print("🔍 Starting zoom and shake")
	var default_zoom := Vector2(3.0, 3.0)
	var start_zoom := default_zoom * 2.0
	zoom = start_zoom

	var tween := create_tween()
	tween.tween_property(self, "zoom", default_zoom, 0.6) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)

	add_trauma(0.5)

func _on_black_hole_spawned():
	print("💥 Camera received black hole signal")
	add_trauma(0.4)

func _on_player_damaged() -> void:
	if shake_on_cooldown:
		print("⏳ Shake on cooldown — skipping")
		return

	shake_on_cooldown = true
	print("💢 Player damaged — triggering trauma")
	add_trauma(0.3)
	animation_player.play("Red")

	await get_tree().create_timer(0.2).timeout 
	trauma = 0.0
	print("🧘 Trauma reset after cooldown")

	await get_tree().create_timer(0.0).timeout
	shake_on_cooldown = false
	print("✅ Shake cooldown ended")
