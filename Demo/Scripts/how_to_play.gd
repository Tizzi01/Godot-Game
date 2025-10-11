extends Control

@onready var shop_scene = preload("res://Demo/Scenes/shop.tscn")
@onready var shop_button: Button = $Shop
@onready var panel: Panel = $Panel
@onready var color_rect: ColorRect = $ColorRect

func _on_back_pressed() -> void:
	Click.play_ClickSound()
	get_tree().change_scene_to_file("res://Folder/Scenes/main_menu.tscn")

func _on_shop_pressed() -> void:
	Click.play_ClickSound()

	var shop_instance = shop_scene.instantiate()
	shop_instance.name = "ShopOverlay"

	# ✅ Show the dark overlay
	color_rect.visible = true

	# ✅ Add shop to the scene (you control layer order manually)
	add_child(shop_instance)

	# ✅ Disable the shop button
	shop_button.disabled = true

	# ✅ Connect to shop exit to clean up
	shop_instance.tree_exited.connect(_on_shop_closed)

func _on_shop_closed() -> void:
	# ✅ Hide the overlay
	color_rect.visible = false

	# ✅ Re-enable the shop button
	shop_button.disabled = false
