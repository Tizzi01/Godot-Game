extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
@onready var animation_player = $AnimationPlayer
@onready var sprites = [ $"0", $"1", $"2" ]  # These are just visuals, not animated individually

func _physics_process(delta):
	# Movement toward player
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 100.0
	move_and_slide()

	# Flip visuals to face player
	var should_flip = player.global_position.x < global_position.x
	for sprite in sprites:
		if sprite:
			sprite.flip_h = should_flip

	# Trigger animation based on movement
	var is_moving = velocity.length() > 0.1
	var current_anim = animation_player.current_animation

	if is_moving and current_anim != "walk":
		animation_player.play("walk")
	elif not is_moving and current_anim != "idle":
		animation_player.play("walk") 
		
