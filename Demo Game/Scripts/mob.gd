extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
@onready var sprites = [ $"0", $"1", $"2" ]  # Make sure these are Sprite2D or AnimatedSprite2D

func _ready():
	for sprite in sprites:
		if sprite:
			print("Found sprite:", sprite.name)
		else:
			print("Missing sprite!")

func _physics_process(delta):
	# Move toward the player
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 100.0
	move_and_slide()

	# Flip sprites to face the player
	var should_flip = player.global_position.x < global_position.x

	print("Mob X:", global_position.x)
	print("Player X:", player.global_position.x)
	print("Should flip:", should_flip)

	for sprite in sprites:
		if sprite:
			sprite.flip_h = should_flip
			print("Flipping sprite:", sprite.name, "→ flip_h =", should_flip)
