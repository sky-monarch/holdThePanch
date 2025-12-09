extends Control
func _ready():
	# Получаем данные из SaveSystem
	var data = SaveSystem.game_data  # Если SaveSystem в AutoLoad
	
	# Обновляем текст
	$Panel/Panel/KillsP1.text = "Убийств: " + str(data["player1"]["kills"])
	$Panel/Panel/DamageP1.text = "Урон: " + str(data["player1"]["damage"])
	$Panel/Panel/HealthP1.text = "Здоровье: " + str(data["player1"]["max_health"])
	
	$Panel/Panel2/KillsP2.text = "Убийств: " + str(data["player2"]["kills"])
	$Panel/Panel2/DamageP2.text = "Урон: " + str(data["player2"]["damage"])
	$Panel/Panel2/HealthP2.text = "Здоровье: " + str(data["player2"]["max_health"]) 


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes_for_main_menu/main_menu.tscn")
