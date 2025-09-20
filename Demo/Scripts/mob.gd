extends CharacterBody2D

var health = 10

@onready var player = get_node("/root/Game/Player")
@onready var animation_player = $AnimationPlayer
@onready var sprites = [ $"0", $"1", $"2" ]  # These are just visuals, not animated individually
@onready var hit_flash: AnimationPlayer = $HitFlash

signal died

func _ready():
	var game_node = get_tree().get_root().get_node("Game")
	if game_node:
		game_node.game_over_triggered.connect(_on_game_over_triggered)

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

func take_damage(): 
	health -= 10
	hit_flash.play("Hitflash")
	
	if health == 0: 
		died.emit()
		queue_free() 
		const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = SMOKE_SCENE.instantiate() 
		get_parent().add_child(smoke)
		smoke.global_position = global_position

func _on_game_over_triggered():
	queue_free()
