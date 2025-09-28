extends Area2D

@onready var omni: AudioStreamPlayer = $Omni
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var up: AudioStreamPlayer = $up

var hold_timer := 0.0
var hold_threshold := 1.5
var has_spawned := false

func _physics_process(delta: float) -> void:
	print("🔄 _physics_process running | delta:", delta)

	if Input.is_action_pressed("slash"): 
		print("🖱️ 'slash' is being held")
		hold_timer += delta
		print("⏱️ Hold timer:", hold_timer, "| Threshold:", hold_threshold, "| Spawned:", has_spawned)

		if animation_player and animation_player.current_animation != "charge":
			print("🎞️ Playing charge animation")
			animation_player.play("charge") 
			up.play() 

		if hold_timer >= hold_threshold and not has_spawned:
			print("🚀 Threshold reached — spawning black hole")
			var power = preload("res://Demo/Scenes/power.tscn").instantiate()
			power.global_position = get_global_mouse_position()
			get_tree().current_scene.add_child(power)
			print("🌀 Black hole instance added to scene")

			power.add_to_group("black")
			print("📦 Added black hole to group 'black'")

			# 🔗 Connect signal to camera
			var camera = get_tree().get_root().get_node("Game/Player/Camera2D")
			if camera:
				print("🎯 Found camera node:", camera.name)
				if power.has_signal("black_hole_spawned"):
					print("📡 Signal 'black_hole_spawned' exists on power")
					var result = power.black_hole_spawned.connect(Callable(camera, "_on_black_hole_spawned"))
					if result == OK:
						print("✅ Connected black hole signal to camera")
					else:
						print("❌ Failed to connect signal to camera")
				else:
					print("⚠️ Signal 'black_hole_spawned' NOT found on power")
			else:
				print("🚫 Camera node not found")

			has_spawned = true
	else:
		print("🛑 'slash' not held")

	if Input.is_action_just_released("slash"):
		print("🔁 'slash' released — resetting timer and spawn flag")
		hold_timer = 0.0
		has_spawned = false

func play_change_animation():
	print("🎬 play_change_animation called")
	var anim = get_node_or_null("AnimationPlayer")
	if anim:
		print("🎞️ AnimationPlayer found — playing 'change'")
		anim.play("change")
	else:
		print("⚠️ No AnimationPlayer found")

	if omni:
		print("🔊 Playing omni sound")
		omni.play()
	else:
		print("⚠️ No omni sound found")
