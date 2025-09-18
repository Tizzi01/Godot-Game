extends Node

@onready var text_box_scene = preload("res://Demo/Scenes/text_box.tscn")

var text_box
var text_box_position: Vector2
var dialog_lines: Array[String]
var current_line_index: int = 0

var is_dialog_active = false
var can_advance_line = false

func start_dialog(position: Vector2, lines: Array[String]):
	if is_dialog_active:
		print("Dialog already active. Skipping.")
		return

	dialog_lines = lines
	current_line_index = 0
	text_box_position = position
	_show_text_box()
	is_dialog_active = true

func _show_text_box():
	text_box = text_box_scene.instantiate()

	var ui_layer = get_tree().current_scene.get_node("CanvasLayer3")
	if ui_layer:
		ui_layer.add_child(text_box)
	else:
		print("❌ CanvasLayer3 not found!")
		return

	text_box.position = text_box_position
	text_box.visible = true
	text_box.modulate.a = 1.0

	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	text_box.display_text(dialog_lines[current_line_index])
	can_advance_line = false

func _on_text_box_finished_displaying():
	await get_tree().create_timer(3.0).timeout

	var tween = create_tween()
	tween.tween_property(text_box, "modulate:a", 0.0, 1.0)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	await tween.finished
	text_box.queue_free()
	text_box = null
	is_dialog_active = false
	current_line_index = 0  # working version 10/10
