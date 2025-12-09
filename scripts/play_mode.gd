extends Control

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Worlds/TileSets/world6(multiplayer mode).tscn")



func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes_for_main_menu/main_menu.tscn")


func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_tree().change_scene_to_file("res://Worlds/TileSets/world1.tscn")
			


func _on_panel_2_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_tree().change_scene_to_file("res://Worlds/TileSets/world6(multiplayer mode).tscn")
