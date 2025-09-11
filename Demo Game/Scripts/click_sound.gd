extends Node

var UI3 : AudioStreamPlayer
var ClickSound : AudioStreamPlayer

var sounds = {}
var root_path : NodePath = "MainMenu" # adjust this to your UI root node path

func _ready() -> void:
	assert(root_path != null, "Empty root path for Interface Sounds")

	# set up audio stream players and load sound files
	for strId in ["UI3", "ClickSound"]:
		var sound = AudioStreamPlayer.new()
		sound.stream = load("res://%s.ogg" % strId)
		sounds[strId] = sound
		add_child(sound)

	# connect signals to the method that plays the sounds
	install_sounds(get_node(root_path))


func install_sounds(node: Node) -> void:
	for main_menu in node.get_children():
		if main_menu is Button:
			main_menu.mouse_entered.connect(ui_sfx_play.bind("UI3"))
			main_menu.pressed.connect(ui_sfx_play.bind("ClickSound"))

		elif main_menu is OptionButton:
			main_menu.mouse_entered.connect(ui_sfx_play.bind("UI3"))
			main_menu.pressed.connect(ui_sfx_play.bind("ClickSound"))

		elif main_menu is TextEdit:
			main_menu.mouse_entered.connect(ui_sfx_play.bind("UI3"))
			main_menu.text_submitted.connect(ui_sfx_play.bind("ClickSound"))

		elif main_menu is LineEdit:
			main_menu.mouse_entered.connect(ui_sfx_play.bind("UI3"))
			main_menu.focus_entered.connect(ui_sfx_play.bind("UI3"))

		elif main_menu is TabContainer:
			main_menu.tab_hovered.connect(ui_sfx_play.bind("UI3"))
			main_menu.tab_selected.connect(ui_sfx_play.bind("ClickSound"))
			main_menu.tab_closed.connect(ui_sfx_play.bind("UI3"))

		# recursively add sounds for children
		install_sounds(main_menu)


func ui_sfx_play(sound : String) -> void:
	sounds[sound].play()
