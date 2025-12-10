extends Control

var death_check_timer: Timer

func _ready():
	# Сразу скрываем меню
	visible = false
	
	# Ждем чтобы все узлы загрузились
	await get_tree().process_frame
	
	# Проверяем состояние игроков
	check_players_state()

func check_players_state():
	# Ждем немного чтобы игроки успели создаться в сцене
	await get_tree().create_timer(0.2).timeout
	
	# Проверяем всех игроков
	check_all_players()

func check_all_players():
	# Получаем всех игроков в группе
	var players = get_tree().get_nodes_in_group("player")
	
	if players.size() == 0:
		print("Игроки не найдены в группе 'player'")
		start_checking_players()
		return
	
	# Проверяем, есть ли хотя бы один мертвый игрок
	for player in players:
		if player.is_died:
			show_menu()
			return
	
	# Если ни один не мертв, запускаем периодическую проверку
	start_checking_players()

func start_checking_players():
	# Если уже есть таймер, удаляем его
	if death_check_timer and death_check_timer.is_inside_tree():
		death_check_timer.queue_free()
	
	# Создаем новый таймер для периодической проверки
	death_check_timer = Timer.new()
	add_child(death_check_timer)
	death_check_timer.wait_time = 0.3
	death_check_timer.timeout.connect(_check_players_continuous)
	death_check_timer.start()

func _check_players_continuous():
	# Если меню уже показано, останавливаем проверку
	if visible:
		if death_check_timer:
			death_check_timer.stop()
		return
	
	# Получаем всех игроков
	var players = get_tree().get_nodes_in_group("player")
	
	# Проверяем, есть ли хотя бы один мертвый игрок
	for player in players:
		if player.is_died:
			show_menu()
			if death_check_timer:
				death_check_timer.stop()
			return

func show_menu():
	# Останавливаем таймер
	if death_check_timer and death_check_timer.is_inside_tree():
		death_check_timer.stop()
	
	# ЗАГРУЖАЕМ СТАТИСТИКУ ПЕРЕД ПОКАЗОМ МЕНЮ
	load_statistics()
	
	# Показываем меню и ставим игру на паузу
	visible = true
	get_tree().paused = true
	print("Меню смерти показано")

func load_statistics():
	# Загружаем статистику игроков
	# Проверяем существование SaveSystem
		# ОТЛАДОЧНЫЙ ВЫВОД
		print("SaveSystem найден")
		print("Текущие данные SaveSystem:")
		print(SaveSystem.game_data)
		
		# Сохраняем данные игроков перед показом
		var players = get_tree().get_nodes_in_group("player")
		print("Найдено игроков: ", players.size())
		
		for player in players:
			if player.has_method("save_data"):
				print("Сохранение данных для: ", player.name)
				player.save_data()
		
		# Получаем обновленные данные
		var data = SaveSystem.game_data
		print("Данные после сохранения:")
		print(data)
		
		# Обновляем текст
		$Panel/Panel/KillsP1.text = "Убийств: " + str(data["player1"]["kills"])
		$Panel/Panel/DamageP1.text = "Урон: " + str(data["player1"]["damage"])
		$Panel/Panel/HealthP1.text = "Здоровье: " + str(data["player1"]["max_health"])
		
		$Panel/Panel2/KillsP2.text = "Убийств: " + str(data["player2"]["kills"])
		$Panel/Panel2/DamageP2.text = "Урон: " + str(data["player2"]["damage"])
		$Panel/Panel2/HealthP2.text = "Здоровье: " + str(data["player2"]["max_health"])

func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_button_3_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/scenes_for_main_menu/main_menu.tscn")

func _exit_tree():
	if death_check_timer and death_check_timer.is_inside_tree():
		death_check_timer.queue_free()
