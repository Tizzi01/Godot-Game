extends Camera2D

@export var decay : float = 1.2
@export var max_offset : Vector2 = Vector2(10, 6)  # 🔧 Softer shake
@export var max_roll : float = 0.01               # 🔧 Less rotation
@export var follow_node : Node2D

var trauma : float = 0.0
var trauma_power : int = 1

func _ready() -> void:
	randomize()
	startup_zoom_and_shake()

func _process(delta: float) -> void:
	if follow_node:
		global_position = follow_node.global_position

	if trauma > 0.0:
		trauma = max(trauma - decay * delta, 0.0)
		shake()

func add_trauma(amount : float) -> void:
	trauma = min(trauma + amount, 1.0)

func shake() -> void:
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)

func add_vertical_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)
	offset.x = 0
	rotation = 0

func _on_item_acquired():
	add_trauma(0.3)

func startup_zoom_and_shake():
	var default_zoom := Vector2(3.0, 3.0)     # Your actual zoom
	var start_zoom := default_zoom * 2.0      # Start zoomed out (3.3, 3.3)

	zoom = start_zoom

	var tween := create_tween()
	tween.tween_property(self, "zoom", default_zoom, 0.6) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)

	add_trauma(0.5)  # Light shake
