extends Area2D

class_name Portal

# Настройки
@export var spawn_delay: float = 8
@export var min_spawn_delay: float = 12  
@export var difficulty_curve: Curve  # Кривая сложности (опционально)
@export var enemy_scenes: Array[PackedScene] = []  # Сцены врагов для спавна

# Ссылки на узлы
@onready var spawn_timer: Timer = $Timer
@onready var animation_player = $AnimatedSprite2D

# Текущее состояние
var player_in_area: bool = false
var current_delay: float
var game_start_time: float = 0.0
var has_spawned_first_enemy: bool = false  # Флаг первого спавна

func _ready():
	# Инициализация
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	# Запоминаем время создания портала
	game_start_time = Time.get_unix_time_from_system()
	
	# Начальная настройка задержки
	update_spawn_delay()
	
	# Запускаем анимацию портала
	if animation_player:
		animation_player.play("Idle")
	

func _process(_delta):
	# Обновляем задержку спавна в реальном времени
	if player_in_area and not spawn_timer.is_stopped():
		update_spawn_delay()
		spawn_timer.wait_time = current_delay

func update_spawn_delay():
	# Получаем время игры
	var game_duration: float = get_game_duration()
	
	# Рассчитываем задержку на основе времени игры
	current_delay = calculate_dynamic_delay(game_duration)
	
func get_game_duration() -> float:
	# Время с момента создания портала
	return Time.get_unix_time_from_system() - game_start_time

func calculate_dynamic_delay(game_duration: float) -> float:
	# Формула: delay = min_delay + (base_delay - min_delay) * e^(-time/scale_factor)
	
	var scale_factor: float = 1200.0  # Медленное уменьшение
	var base_delay: float = spawn_delay
	var min_delay: float = min_spawn_delay
	
	# Используем экспоненциальное уменьшение
	var calculated_delay = min_delay + (base_delay - min_delay) * exp(-game_duration / scale_factor)
	
	# Гарантируем, что задержка не меньше минимальной
	return max(min_delay, calculated_delay)

func _on_body_entered(body: Node2D):
	# Проверяем, что вошел игрок
	if body.is_in_group("player") and not player_in_area:
		player_in_area = true
		
		# 1. Спавним врага сразу же
		if not has_spawned_first_enemy:
			spawn_enemy_immediately()
		else:
			# 2. Если уже спавнили первого, запускаем таймер
			update_spawn_delay()
			spawn_timer.wait_time = current_delay
			spawn_timer.start()

func spawn_enemy_immediately():
	# Спавним врага без задержки
	if enemy_scenes.is_empty():
		print("Нет врагов для спавна!")
		return
	
	# Выбираем случайного врага
	var enemy_scene = enemy_scenes.pick_random()
	var enemy_instance = enemy_scene.instantiate()
	
	# Устанавливаем позицию врага у портала
	enemy_instance.global_position = global_position
	
	# Добавляем врага на сцену
	get_parent().add_child(enemy_instance)
	
	has_spawned_first_enemy = true
	
	# Запускаем таймер для следующего спавна
	if player_in_area:
		update_spawn_delay()
		spawn_timer.wait_time = current_delay
		spawn_timer.start()

func _on_body_exited(body: Node2D):
	if body.is_in_group("player") and player_in_area:
		player_in_area = false
		
		# Останавливаем таймер, если игрок вышел
		spawn_timer.stop()
		

func _on_spawn_timer_timeout():
	# Спавним врага
	spawn_enemy()
	
	# Перезапускаем таймер с обновленной задержкой
	if player_in_area:
		update_spawn_delay()
		spawn_timer.wait_time = current_delay
		spawn_timer.start()

func spawn_enemy():
	if enemy_scenes.is_empty():
		return
	
	# Выбираем случайного врага
	var enemy_scene = enemy_scenes.pick_random()
	var enemy_instance = enemy_scene.instantiate()
	
	# Устанавливаем позицию врага у портала
	enemy_instance.global_position = global_position
	
	# Добавляем врага на сцену
	get_parent().add_child(enemy_instance)
	
	# Устанавливаем флаг, если это первый спавн
	if not has_spawned_first_enemy:
		has_spawned_first_enemy = true

# Метод для сброса состояния портала
func reset_portal():
	has_spawned_first_enemy = false
	spawn_timer.stop()
	player_in_area = false
