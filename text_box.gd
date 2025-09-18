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
	print("STEP 1: _ready() called")
	print("🔍 Beep node exists:", beep != null)
	print("🔍 Beep stream assigned:", beep.stream != null)
	print("🔍 Beep volume_db:", beep.volume_db)
	print("🔍 Beep bus:", beep.bus)
	letter_display_timer.timeout.connect(_on_letter_display_timer_timeout)
	print("STEP 2: Timer signal connected")

func display_text(text_to_display: String):
	print("STEP 3: display_text() called")
	text = text_to_display
	print("STEP 4: Text set to:", text)
	letter_index = 0
	print("STEP 5: letter_index reset to 0")
	word_count = 0
	print("STEP 5.1: word_count reset to 0")
	label.text = ""
	print("STEP 6: Label cleared")
	custom_minimum_size.x = 655
	label.custom_minimum_size.x = 655
	print("STEP 7: custom_minimum_size.x set to:", custom_minimum_size.x)

	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		print("STEP 8: Autowrap enabled")
		custom_minimum_size.y = size.y
		print("STEP 9: custom_minimum_size.y set to:", custom_minimum_size.y)

	await get_tree().process_frame

	var screen_size = get_viewport().get_visible_rect().size
	var box_size = background.size

	var margin = Vector2(-12, 980)
	global_position = screen_size - box_size - margin
	print("📍 Text box positioned at:", global_position)
	print("STEP 10: global_position set to:", global_position)

	print("STEP 11: Calling _display_letter()")
	_display_letter()

func _display_letter():
	print("STEP 12: _display_letter() called")

	if letter_index >= text.length():
		print("STEP 13: Finished displaying text")
		finished_displaying.emit()
		return

	var char = text[letter_index]
	print("STEP 14: Current character:", char, "at index:", letter_index)

	label.text += char
	print("STEP 15: Label updated to:", label.text)

	# 🔊 STEP 15.3: Play beep sound with randomized pitch
	if char != " " and char != "\n":
		print("🔍 Tree paused:", get_tree().paused)
		print("🔍 Beep is inside tree:", beep.is_inside_tree())
		print("🔍 Beep stream valid:", beep.stream != null)
		print("🔍 Beep is playing:", beep.is_playing())
		print("🔍 Beep volume_db:", beep.volume_db)
		print("🔍 Beep bus:", beep.bus)

		if beep != null and beep.stream != null and beep.is_inside_tree():
			beep.pitch_scale = randf_range(0.95, 1.05)
			print("🔊 Beep pitch set to:", beep.pitch_scale)
			beep.stop()
			print("🔊 Beep stopped before playing")
			beep.play()
			print("🔊 Beep played")
		else:
			print("❌ Beep playback skipped — node or stream not ready")

	if char == " ":
		word_count += 1
		print("STEP 15.1: word_count incremented to:", word_count)
		if word_count >= 12:
			label.text += "\n"
			print("STEP 15.2: Inserted line break after 5 words")
			word_count = 0

	await get_tree().process_frame
	var label_size = label.get_combined_minimum_size()
	var padded_size = label_size + Vector2(32, 32)
	background.size = padded_size
	print("STEP 15.5: Background resized to:", padded_size)

	letter_index += 1
	print("STEP 16: letter_index incremented to:", letter_index)

	match char:
		".", ",", "!", "?", ":":
			print("STEP 17: Starting timer with punctuation_time:", punctuation_time)
			letter_display_timer.start(punctuation_time)
		" ":
			print("STEP 18: Starting timer with space_time:", space_time)
			letter_display_timer.start(space_time)
		_:
			print("STEP 19: Starting timer with letter_time:", letter_time)
			letter_display_timer.start(letter_time)

func _on_letter_display_timer_timeout():
	print("STEP 20: Timer timeout — calling _display_letter() again")
	_display_letter() 
