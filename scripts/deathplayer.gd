extends CanvasLayer

func _ready():
	# Сразу скрываем меню
	visible = false
	
	# Ждем чтобы все узлы загрузились
	await get_tree().process_frame
	
	# Проверяем состояние игрока
	check_player_state()

func check_player_state():
	# Ждем немного чтобы игрок успел создаться в сцене
	await get_tree().create_timer(0.1).timeout
	
	# Ищем игрока по группе
	var player = get_tree().get_first_node_in_group("player")
	
	# Если нашли игрока и он мертв - показываем меню
	if player and player.has_method("die") and player.is_died:
		show_menu()
	else:
		# Если игрок еще жив, проверяем периодически
		start_checking_player()

func start_checking_player():
	# Создаем таймер для периодической проверки
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5  # Проверяем каждые 0.5 секунды
	timer.timeout.connect(_check_player_continuous)
	timer.start()

func _check_player_continuous():
	# Если меню уже показано, останавливаем проверку
	if visible:
		return
		
	var player = get_tree().get_first_node_in_group("player")
	if player and player.is_died:
		show_menu()

func show_menu():
	visible = true
	get_tree().paused = true
	print("Меню смерти показано - персонаж мертв")


func _on_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://Worlds/TileSets/world1.tscn")
	get_tree().reload_current_scene()
	



func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes_for_main_menu/main_menu.tscn")
