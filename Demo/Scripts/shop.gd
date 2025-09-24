extends Control

@onready var space_shift_button = $SpaceShift
@onready var back_button = $Back
var shop_open = false
@onready var animation_player: AnimationPlayer = $Panel/Sprite2D/AnimationPlayer

# 📢 Signals
signal shop_closed
signal space_shift_button_pressed  # ✅ New signal

func _ready() -> void:
	animation_player.play("ShopIdle")
	# Scale the shop to 80% of its original size
	scale = Vector2(0.75, 0.75)

	# Optional: center it on screen
	var screen_size = get_viewport().get_visible_rect().size
	position = (screen_size - size * scale) / 2

	# Connect buttons safely
	if space_shift_button:
		space_shift_button.pressed.connect(_on_space_shift_pressed)
	else:
		print("❌ SpaceShift button not found")

	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	else:
		print("❌ Back button not found")

func _on_space_shift_pressed() -> void:
	var player_list = get_tree().get_nodes_in_group("player")
	if player_list.size() == 0:
		print("❌ No player found in 'player' group")
		return

	var player = player_list[0]
	print("🔍 Shop: player from group =", player)

	var cost = 5
	if PointsManager.points >= cost:
		PointsManager.add_points(-cost)
		print("🛸 SpaceShift purchased! -5 points")

		player.has_space_shift = true
		print("🛠️ Shop: has_space_shift set to", player.has_space_shift)

		# ✅ Emit signal ONLY after successful purchase
		emit_signal("space_shift_button_pressed")
		print("📡 Signal emitted: space_shift_button_pressed")
	else:
		print("❌ Not enough money for SpaceShift")

func _on_back_pressed() -> void:
	var camera = get_tree().current_scene.get_node("Camera2D")
	if camera:
		var tween = create_tween()
		tween.tween_property(camera, "zoom", Vector2(1, 1), 0.2)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)

	var tween = create_tween()
	var end_y = -get_viewport().get_visible_rect().size.y
	tween.tween_property(self, "position:y", end_y, 0.25)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)

	await tween.finished
	emit_signal("shop_closed")
	queue_free()
