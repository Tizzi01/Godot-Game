extends Area2D

const BULLET = preload("res://Folder/Scenes/bullet_v_2.tscn")
const ROTATION_OFFSET := PI / 2  # ✅ Correct offset for upward-facing gun

@onready var gun_pivot = $GunPivot
@onready var shooting_point = $GunPivot/Sprite2D/ShootingPoint

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	monitoring = true

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		print("Chest touched by:", body.name)
		var gun = body.get_node("gun")
		gun.visible = true
		gun.set_process(true)
		queue_free()

func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	var target_angle = (mouse_pos - gun_pivot.global_position).angle() + ROTATION_OFFSET
	gun_pivot.rotation = lerp_angle(gun_pivot.rotation, target_angle, 10 * delta)

	if Input.is_action_just_pressed("slash"):
		$AnimationPlayer.play("slash")
		shoot()

func shoot():
	if shooting_point == null:
		print("ERROR: ShootingPoint not found")
		return
	
	var bullet_instance = BULLET.instantiate()
	bullet_instance.top_level = true
	bullet_instance.global_position = shooting_point.global_position

	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - shooting_point.global_position).normalized()
	var angle_to_cursor = direction.angle()
	bullet_instance.rotation = angle_to_cursor

	get_tree().current_scene.add_child(bullet_instance)


	

	
