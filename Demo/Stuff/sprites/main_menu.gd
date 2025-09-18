extends Control
var game_scene = preload("res://Folder/Scenes/game.tscn")
var Beep = preload("res://Demo/Stuff/music/Beep .mp3")
func _ready():
	IntroMusic1.play_IntroMusic()


func _on_play_pressed() -> void:
	AnimeShine.play_ClickSound()
	get_tree().change_scene_to_file("res://Folder/Scenes/game.tscn")
	
func _on_settings_pressed() -> void:
	Click.play_ClickSound()
	get_tree().change_scene_to_file("res://Folder/Scenes/settings.tscn")

func _on_controls_pressed() -> void:
	Click.play_ClickSound()
	get_tree().change_scene_to_file("res://Folder/Scenes/how_to_play.tscn")
