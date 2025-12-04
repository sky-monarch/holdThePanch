# CorrectCamera.gd - РАБОЧАЯ ВЕРСИЯ
extends Node2D

@onready var player1 = $player
@onready var player2 = $player_two
@onready var camera = $MainCamera

# ПРАВИЛЬНЫЕ НАСТРОЙКИ:
@export var min_zoom: float = 0.3      # МАКСИМАЛЬНОЕ отдаление (объекты крупные)
@export var max_zoom: float = 1.5      # МИНИМАЛЬНОЕ отдаление (объекты мелкие)
@export var smoothness: float = 4.0
@export var padding: float = 200.0     # Отступ от краев экрана

func _ready():
	if not camera or not player1 or not player2:
		print("Ошибка: узлы не найдены")
		return
	
	camera.make_current()
	print("Умная камера активирована")
	
	# Включаем визуальную отладку
	start_debug_display()

func _process(delta):
	if not camera or not player1 or not player2:
		return
	
	update_camera(delta)

func update_camera(delta: float):
	# 1. Получаем позиции игроков
	var p1 = player1.global_position
	var p2 = player2.global_position
	
	# 2. Расстояние между игроками
	var distance = p1.distance_to(p2)
	
	# 3. ВАЖНО ПРАВИЛЬНАЯ ЛОГИКА:
	# Чем БОЛЬШЕ расстояние, тем МЕНЬШЕ зум (камера ОТДАЛЯЕТСЯ)
	
	# Формула: zoom = max_zoom - (distance / масштаб)
	# где max_zoom - это минимальное отдаление (когда игроки рядом)
	
	# Пример:
	# distance = 0 → zoom = max_zoom (1.5) - камера близко
	# distance = 1000 → zoom = ~0.5 - камера далеко
	# distance = 2000 → zoom = min_zoom (0.3) - камера очень далеко
	
	var scale_factor = 1500.0  # На этом расстоянии zoom достигнет min_zoom
	var target_zoom = max_zoom - (distance / scale_factor)
	
	# 4. Ограничиваем
	target_zoom = clamp(target_zoom, min_zoom, max_zoom)
	
	# 5. Центр между игроками
	var center = (p1 + p2) / 2
	
	# 6. Плавное движение
	camera.global_position = camera.global_position.lerp(
		center, 
		delta * smoothness
	)
	
	# 7. Плавный зум
	camera.zoom = camera.zoom.lerp(
		Vector2(target_zoom, target_zoom), 
		delta * smoothness
	)
	
	# Отладка
	debug_info(distance, target_zoom)

func debug_info(distance: float, target_zoom: float):
	print("Дистанция: %.0fpx | Целевой зум: %.2f | Текущий зум: %.2f | %s" % [
		distance,
		target_zoom,
		camera.zoom.x,
		"↗️ Камера ОТДАЛЯЕТСЯ" if target_zoom < camera.zoom.x else 
		"↘️ Камера ПРИБЛИЖАЕТСЯ" if target_zoom > camera.zoom.x else 
		"⏹️ Камера НЕ МЕНЯЕТСЯ"
	])

func start_debug_display():
	# Создаем CanvasLayer для отладки
	var debug_layer = CanvasLayer.new()
	debug_layer.layer = 100
	debug_layer.name = "DebugOverlay"
	add_child(debug_layer)
	
	# Панель информации
	var panel = Panel.new()
	panel.name = "InfoPanel"
	panel.size = Vector2(350, 180)
	panel.position = Vector2(10, 10)
	debug_layer.add_child(panel)
	
	var label = Label.new()
	label.name = "InfoLabel"
	label.position = Vector2(10, 10)
	label.size = Vector2(330, 160)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(label)
	
	# Таймер обновления
	var timer = Timer.new()
	timer.wait_time = 0.2
	timer.autostart = true
	debug_layer.add_child(timer)
	
	timer.timeout.connect(func():
		if not player1 or not player2 or not camera:
			return
		
		var distance = player1.global_position.distance_to(player2.global_position)
		var p1_pos = player1.global_position
		var p2_pos = player2.global_position
		
		label.text = "📏 ДИСТАНЦИЯ: %.0fpx\n" % distance
		label.text += "🔍 ЗУМ КАМЕРЫ: %.2f\n\n" % camera.zoom.x
		label.text += "👤 ИГРОК 1: (%.0f, %.0f)\n" % [p1_pos.x, p1_pos.y]
		label.text += "👤 ИГРОК 2: (%.0f, %.0f)\n\n" % [p2_pos.x, p2_pos.y]
		
		# Объяснение логики
		if distance > 1000:
			label.text += "🎯 СТАТУС: Игроки ДАЛЕКО\n"
			label.text += "   Камера ОТДАЛЯЕТСЯ (zoom ↓)\n"
		elif distance > 500:
			label.text += "🎯 СТАТУС: Игроки НОРМАЛЬНО\n"
			label.text += "   Камера СРЕДНЕ\n"
		else:
			label.text += "🎯 СТАТУС: Игроки БЛИЗКО\n"
			label.text += "   Камера ПРИБЛИЖАЕТСЯ (zoom ↑)\n"
		
		# Визуализация
		draw_distance_line()
	)

func draw_distance_line():
	# Удаляем старые линии
	for child in get_children():
		if child is Line2D and child.name.begins_with("DebugLine"):
			child.queue_free()
	
	# Рисуем линию между игроками
	var line = Line2D.new()
	line.name = "DebugLine"
	line.width = 3
	line.default_color = Color(0, 1, 1, 0.7)
	line.points = PackedVector2Array([player1.global_position, player2.global_position])
	add_child(line)
	
	# Удаляем через 0.2 секунды
	get_tree().create_timer(0.2).timeout.connect(func():
		if is_instance_valid(line):
			line.queue_free()
	)

# Тестовая функция чтобы понять логику
func test_zoom_logic():
	print("=== ТЕСТ ЛОГИКИ ЗУМА ===")
	print("В GODOT:")
	print("  zoom = 2.0 → объекты в 2 раза МЕНЬШЕ (камера 'ближе')")
	print("  zoom = 0.5 → объекты в 2 раза БОЛЬШЕ (камера 'дальше')")
	print("\nНАША ФОРМУЛА:")
	print("  Игроки рядом (0px) → zoom = %.2f (близко)" % max_zoom)
	print("  Игроки далеко (1000px) → zoom = %.2f (далеко)" % (max_zoom - 1000/1500.0))
	print("  Игроки очень далеко (2000px) → zoom = %.2f (очень далеко)" % min_zoom)
	
	# Примеры расчетов
	print("\nРАСЧЕТЫ:")
	for dist in [0, 250, 500, 750, 1000, 1500, 2000]:
		var zoom = max_zoom - (dist / 1500.0)
		zoom = clamp(zoom, min_zoom, max_zoom)
		print("  %4dpx → zoom %.2f → камера %s" % [
			dist, 
			zoom,
			"ОЧЕНЬ БЛИЗКО" if zoom > 1.2 else
			"БЛИЗКО" if zoom > 0.9 else
			"ДАЛЕКО" if zoom > 0.6 else
			"ОЧЕНЬ ДАЛЕКО"
		])
