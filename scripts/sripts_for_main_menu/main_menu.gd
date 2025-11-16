extends Control

@onready var main_button: VBoxContainer = $MainButton
@onready var options: Panel = $Options

func _ready():
	main_button.visible = true
	options.visible = false

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Worlds/world2.tscn")


func _on_settings_pressed() -> void:
	print('setting press')
	main_button.visible = false
	options.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_options_pressed() -> void:
	_ready()
