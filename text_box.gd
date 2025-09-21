extends MarginContainer

@onready var label: Label = $MarginContainer/Label
@onready var letter_display_timer: Timer = $LetterDisplayTimer
@onready var background: NinePatchRect = $NinePatchRect
@onready var beep: AudioStreamPlayer = $Beep

const MAX_WIDTH = 655
const PADDING = Vector2(32, 32)

var text: String = ""
var letter_index: int = 0
var word_count: int = 0

var letter_time := 0.03
var space_time := 0.06
var punctuation_time := 0.2

signal finished_displaying()

func _ready():
	letter_display_timer.timeout.connect(_on_letter_display_timer_timeout)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.text = ""
	label.custom_minimum_size.x = MAX_WIDTH
	custom_minimum_size.x = MAX_WIDTH

func display_text(text_to_display: String):
	text = text_to_display
	letter_index = 0
	word_count = 0
	label.text = ""

	await get_tree().process_frame

	# Calculate final position
	var screen_size = get_viewport().get_visible_rect().size
	var label_size = label.get_combined_minimum_size()
	var padded_size = label_size + PADDING
	background.custom_minimum_size = padded_size

	var final_position = Vector2(screen_size.x - MAX_WIDTH - 70, screen_size.y - 1055)

	# Start off-screen to the right
	global_position = Vector2(screen_size.x + 150, final_position.y)

	# Animate smooth slide-in
	var tween = create_tween()
	tween.tween_property(self, "global_position", final_position, 0.7)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)

	await tween.finished
	_display_letter()

func _display_letter():
	if letter_index >= text.length():
		finished_displaying.emit()
		await get_tree().create_timer(1.0).timeout  # ⏳ Wait 1 second
		animate_exit()
		return

	var char = text[letter_index]
	label.text += char

	# 🔊 Beep for non-space characters
	if char != " " and char != "\n":
		if beep and beep.stream and beep.is_inside_tree():
			beep.pitch_scale = randf_range(0.95, 1.05)
			beep.stop()
			beep.play()

	# Line break after 12 words
	if char == " ":
		word_count += 1
		if word_count >= 12:
			label.text += "\n"
			word_count = 0

	await get_tree().process_frame

	# Resize background based on label content
	var label_size = label.get_combined_minimum_size()
	var padded_size = label_size + PADDING
	background.custom_minimum_size = padded_size

	letter_index += 1

	match char:
		".", ",", "!", "?", ":":
			letter_display_timer.start(punctuation_time)
		" ":
			letter_display_timer.start(space_time)
		_:
			letter_display_timer.start(letter_time)

func _on_letter_display_timer_timeout():
	_display_letter()

func animate_exit():
	var current_pos = global_position
	var pullback_pos = current_pos - Vector2(40, 0)  # Gentle slide left
	var exit_pos = Vector2(get_viewport().get_visible_rect().size.x + 150, current_pos.y)  # Off-screen right

	var tween = create_tween()

	# Step 1: Pull back slightly
	tween.tween_property(self, "global_position", pullback_pos, 0.4)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN_OUT)

	# Step 2: Smooth swoosh out right
	tween.tween_property(self, "global_position", exit_pos, 0.8)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_IN)\
		.set_delay(0.1) 
