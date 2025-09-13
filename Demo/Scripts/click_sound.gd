extends Node

var UI3 : AudioStreamPlayer
var ClickSound : AudioStreamPlayer

var sounds = {}
var root_path : NodePath = "MainMenu"  # Make sure this matches your actual UI container node

func _ready() -> void:
	var root_node = get_node_or_null(root_path)
	if root_node == null:
		print("⚠️ Could not find node at path:", root_path)
		return

	# Set up audio stream players and load sound files
	for strId in ["UI3", "ClickSound"]:
		var sound = AudioStreamPlayer.new()
		sound.stream = load("res://Demo Game/The assets/music/%s.mp3" % strId)
		sounds[strId] = sound
		add_child(sound)

	# Connect signals to play sounds
	install_sounds(root_node)


func install_sounds(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			child.mouse_entered.connect(ui_sfx_play.bind("UI3"))
			child.pressed.connect(ui_sfx_play.bind("ClickSound"))

		elif child is OptionButton:
			child.mouse_entered.connect(ui_sfx_play.bind("UI3"))
			child.pressed.connect(ui_sfx_play.bind("ClickSound"))

		elif child is TextEdit:
			child.mouse_entered.connect(ui_sfx_play.bind("UI3"))
			child.text_submitted.connect(ui_sfx_play.bind("ClickSound"))

		elif child is LineEdit:
			child.mouse_entered.connect(ui_sfx_play.bind("UI3"))
			child.focus_entered.connect(ui_sfx_play.bind("UI3"))

		elif child is TabContainer:
			child.tab_hovered.connect(ui_sfx_play.bind("UI3"))
			child.tab_selected.connect(ui_sfx_play.bind("ClickSound"))
			child.tab_closed.connect(ui_sfx_play.bind("UI3"))

		# Recursively connect children
		install_sounds(child)


func ui_sfx_play(sound: String) -> void:
	if sounds.has(sound):
		sounds[sound].play()
