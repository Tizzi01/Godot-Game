extends Control

@onready var space_shift_button = $SpaceShift
@onready var back_button = $Back
var shop_open = false
signal shop_closed

func _ready() -> void:
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
	var player = get_tree().current_scene.get_node("Player")
	print("🔍 Shop: player node =", player)

	if player and player.has_method("activate_space_shift"):
		player.activate_space_shift()

	var cost = 5
	if PointsManager.points >= cost:
		PointsManager.add_points(-cost)
		print("🛸 SpaceShift purchased! -5 points")

		if player and player.has_method("activate_space_shift"):
			player.activate_space_shift()

			# ✅ Unlock teleport and confirm
			print("🛠️ Shop: Setting has_space_shift to true on player")
			player.has_space_shift = true
			print("🛠️ Shop: player.has_space_shift =", player.has_space_shift)
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
