extends MarginContainer

@onready var label: Label = $MarginContainer/Label
@onready var letter_display_timer: Timer = $LetterDisplayTimer
@onready var background: NinePatchRect = $NinePatchRect
@onready var beep: AudioStreamPlayer = $Beep  # 🔊 Reference to beep node

const MAX_WIDTH = 655

var text: String = ""
var letter_index: int = 0
var word_count: int = 0

var letter_time := 0.03
var space_time := 0.06
var punctuation_time := 0.2

signal finished_displaying()

func _ready():
	letter_display_timer.timeout.connect(_on_letter_display_timer_timeout)

func display_text(text_to_display: String):
	text = text_to_display
	letter_index = 0
	word_count = 0
	label.text = ""
	custom_minimum_size.x = 655
	label.custom_minimum_size.x = 655

	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		custom_minimum_size.y = size.y

	await get_tree().process_frame

	var screen_size = get_viewport().get_visible_rect().size
	var box_size = background.size
	var margin = Vector2(-12, 980)
	global_position = screen_size - box_size - margin

	_display_letter()

func _display_letter():
	if letter_index >= text.length():
		finished_displaying.emit()
		return

	var char = text[letter_index]
	label.text += char

	# 🔊 Play beep sound with randomized pitch
	if char != " " and char != "\n":
		if beep != null and beep.stream != null and beep.is_inside_tree():
			beep.pitch_scale = randf_range(0.95, 1.05)
			beep.stop()
			beep.play()

	if char == " ":
		word_count += 1
		if word_count >= 12:
			label.text += "\n"
			word_count = 0

	await get_tree().process_frame
	var label_size = label.get_combined_minimum_size()
	var padded_size = label_size + Vector2(32, 32)
	background.size = padded_size

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
