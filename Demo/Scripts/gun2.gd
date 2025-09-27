extends Area2D
@onready var omni: AudioStreamPlayer = $Omni






func play_change_animation():
	var anim = get_node_or_null("AnimationPlayer")
	if anim:
		anim.play("change")
	if omni:
		omni.play()
