extends Node

@export var root_path: NodePath
@export var ui3_volume_db: float = -25.0  # Easy tweak for UI3 volume
@export var click_volume_db: float = -25.0  # Easy tweak for Click3 volume

@onready var sounds := {
	"Click3": AudioStreamPlayer.new(),
	"UI3": AudioStreamPlayer.new()
}

func _ready():
	print("Null, Empty root path for UI Sounds!")

	# Add sound players as children and load sound files
	for key in sounds.keys():
		var player = sounds[key]
		add_child(player)
		player.stream = load("res://Demo Game/The assets/music/" + key + ".mp3")

		# Apply volume tweaks
		if key == "UI3":
			player.volume_db = ui3_volume_db
		elif key == "Click3":
			player.volume_db = click_volume_db

		player.connect("finished", Callable(self, "_on_sound_finished").bind(root_path))

	# Install sounds to buttons under the specified root node
	var root_node = get_node(root_path)
	if root_node:
		install_sounds(root_node)

func install_sounds(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			child.mouse_entered.connect(func(): mainmenu_music_play("UI3"))
			child.pressed.connect(func(): mainmenu_music_play("Click3"))
		install_sounds(child)  # Recursive call for nested buttons

func mainmenu_music_play(sound_key: String) -> void:
	if sounds.has(sound_key):
		sounds[sound_key].play()

func _on_sound_finished(root: NodePath) -> void:
	print("Sound finished for node:", root)
