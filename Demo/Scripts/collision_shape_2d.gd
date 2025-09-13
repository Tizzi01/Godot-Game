extends CollisionShape2D

var health: float = 3.0 

func take_damage (weapon_damage: float): 
    $Sprite2D/AnimationPlayer.play("take_damage") 
    health -= m1_damage 

    if health <= 0.0: 
        queue_free()