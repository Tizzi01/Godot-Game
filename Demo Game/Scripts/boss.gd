extends CharacterBody2D

@export var speed := 100
@export var teleport_distance := 200

var player: Node2D

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		push_error("No node found in 'player' group!")

func _physics_process(delta):
	if not player:
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func _on_VisionArea_body_entered(body):
	if body.is_in_group("player"):
		$SightRay.target_position = to_local(body.global_position)
		$SightRay.force_raycast_update()

		if $SightRay.is_colliding() and $SightRay.get_collider() == body:
			print("Player in vision range and visible!")
			$TeleportTimer.start()

func _on_TeleportTimer_timeout():
	if not player:
		return

	var offset = Vector2(
		randf_range(-teleport_distance, teleport_distance),
		randf_range(-teleport_distance, teleport_distance)
	)
	global_position = player.global_position + offset
	$TeleportTimer.stop()
