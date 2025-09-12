extends Control


func _on_back_pressed() -> void:
	Click.play_ClickSound()

	get_tree().change_scene_to_file("res://Assets for the acual game/Scenes/main_menu.tscn")
	
