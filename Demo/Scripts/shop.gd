extends Control

@onready var space_shift_button = $SpaceShift
@onready var back_button = $Back
@onready var singularity_button = $Singularity
@onready var wave: Button = $Wave

@onready var animation_player: AnimationPlayer = $Panel/Sprite2D/AnimationPlayer
@onready var woosh: AudioStreamPlayer = $woosh
@onready var nop: AudioStreamPlayer = $nop
@onready var money: AudioStreamPlayer = $money

const BUZZER_BUTTON_S_08TE_317__SFX_ = preload("res://Demo/Stuff/music/BuzzerButton_S08TE.317 (SFX).mp3")

# 📢 Signals
signal shop_closed
signal space_shift_button_pressed
signal black_hole_button_pressed
signal shockwave_button_pressed

func _ready() -> void:
	animation_player.play("ShopIdle")
	scale = Vector2(0.75, 0.75)

	var screen_size = get_viewport().get_visible_rect().size
	var start_y = -screen_size.y
	var target_y = (screen_size.y - size.y * scale.y) / 2
	position = Vector2((screen_size.x - size.x * scale.x) / 2, start_y)

	var tween = create_tween()
	tween.tween_property(self, "position:y", target_y, 0.25)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	if woosh:
		woosh.play()

	if space_shift_button:
		space_shift_button.pressed.connect(_on_space_shift_pressed)
	else:
		print("❌ SpaceShift button not found")

	if singularity_button:
		singularity_button.pressed.connect(_on_singularity_pressed)
	else:
		print("❌ Singularity button not found")

	if wave:
		wave.pressed.connect(_on_wave_pressed)
	else:
		print("❌ Wave button not found")

	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	else:
		print("❌ Back button not found")

	var player_list = get_tree().get_nodes_in_group("player")
	if player_list.size() > 0:
		var player = player_list[0]
		if player.has_space_shift:
			space_shift_button.disabled = true
		if player.black_hole_unlocked:
			singularity_button.disabled = true
		if player.has_shockwave:
			wave.disabled = true

func _on_space_shift_pressed() -> void:
	var player_list = get_tree().get_nodes_in_group("player")
	if player_list.size() == 0:
		print("❌ No player found in 'player' group")
		return

	var player = player_list[0]
	var cost = 5
	if PointsManager.points >= cost:
		PointsManager.add_points(-cost)
		print("🛸 SpaceShift purchased! -5 points")

		player.has_space_shift = true
		space_shift_button.disabled = true
		emit_signal("space_shift_button_pressed")
		money.play()
	else:
		print("❌ Not enough money for SpaceShift")
		if nop:
			nop.play()

func _on_singularity_pressed() -> void:
	var player_list = get_tree().get_nodes_in_group("player")
	if player_list.size() == 0:
		print("❌ No player found in 'player' group")
		return

	var player = player_list[0]
	if player.black_hole_unlocked:
		singularity_button.disabled = true
		print("❌ Already purchased — can't buy again")
		return

	var cost = 5
	if PointsManager.points >= cost:
		PointsManager.add_points(-cost)
		print("🌌 Black Hole purchased! -5 points")

		player._on_black_hole_signal_received()
		singularity_button.disabled = true
		emit_signal("black_hole_button_pressed")
		money.play()
	else:
		print("❌ Not enough money for Black Hole")
		if nop:
			nop.play()

func _on_wave_pressed() -> void:
	var player_list = get_tree().get_nodes_in_group("player")
	if player_list.size() == 0:
		print("❌ No player found in 'player' group")
		return

	var player = player_list[0]
	if player.has_shockwave:
		wave.disabled = true
		print("❌ Already purchased — can't buy again")
		return

	var cost = 5
	if PointsManager.points >= cost:
		PointsManager.add_points(-cost)
		print("💥 Shockwave purchased! -5 points")

		player.has_shockwave = true
		wave.disabled = true
		emit_signal("shockwave_button_pressed")
		money.play()
	else:
		print("❌ Not enough money for Shockwave")
		if nop:
			nop.play()

func _on_back_pressed() -> void:
	var camera = get_tree().current_scene.get_node("Camera2D")
	if camera:
		var tween = create_tween()
		tween.tween_property(camera, "zoom", Vector2(1, 1), 0.2)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)

	if woosh:
		woosh.play()

	var tween = create_tween()
	var end_y = -get_viewport().get_visible_rect().size.y
	tween.tween_property(self, "position:y", end_y, 0.25)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)

	await tween.finished
	await get_tree().create_timer(0.0).timeout
	emit_signal("shop_closed")
	queue_free()
