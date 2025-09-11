extends Control



func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets for the acual game/Scenes/game.tscn")
	
func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets for the acual game/Scenes/settings.tscn")


func _on_controls_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets for the acual game/Scenes/how_to_play.tscn")
