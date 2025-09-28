extends CharacterBody2D

var health = 10
var last_known_direction := Vector2.ZERO
var is_being_pulled := false  # Flag to detect suction state

@onready var player = get_node("/root/Game/Player")
@onready var animation_player = $AnimationPlayer
@onready var sprites = [ $"0", $"1", $"2" ]  # Visual layers
@onready var hit_flash: AnimationPlayer = $HitFlash

signal died

func _ready():
	add_to_group("Mob")
	var game_node = get_tree().get_root().get_node("Game")
	if game_node:
		game_node.game_over_triggered.connect(_on_game_over_triggered)

func _physics_process(delta):
	var move_direction := Vector2.ZERO

	if not is_being_pulled:
		# Normal movement toward player
		if not player.is_hidden_from_mobs:
			move_direction = global_position.direction_to(player.global_position)
			last_known_direction = move_direction
		else:
			move_direction = last_known_direction

		velocity += move_direction * 100.0  # Player chase speed

	# Suction force is added externally by Power.gd
	move_and_slide()
	velocity = Vector2.ZERO  # Reset after movement

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

func take_damage():
	health -= 10
	hit_flash.play("Hitflash")

	if health <= 0:
		died.emit()
		queue_free()
		const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position

func _on_game_over_triggered():
	queue_free()
