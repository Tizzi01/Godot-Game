extends Camera2D
@export var decay : float = 1.2
@export var max_offset : Vector2 = Vector2(30, 20)
@export var max_roll : float = 0.03
@export var follow_node : Node2D

var trauma : float = 0.0
var trauma_power : int = 1

	

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	if follow_node:
		global_position = follow_node.global_position

	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func add_trauma(amount : float) -> void:
	trauma = min(trauma + amount, 1.0)

func shake() -> void:
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)

func _on_item_acquired():
	add_trauma(0.3)
