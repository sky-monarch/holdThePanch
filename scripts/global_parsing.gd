# SaveSystem.gd
extends Node
class_name SaveSystem

# Константы
const SAVE_FILE_PATH = "user://savegame.dat"

# Данные для сохранения
var game_data = {
	"difficulty": 1,
	"time": 0.0,
	"player1": {
		"max_health": 100,
		"current_health": 100,
		"damage": 10,
		"kills": 0,
		"position_x": 0.0,
		"position_y": 0.0,
		"collected_items": []
	},
	"player2": {
		"max_health": 100,
		"current_health": 100,
		"damage": 10,
		"kills": 0,
		"position_x": 100.0,
		"position_y": 0.0,
		"collected_items": []
	},
	"timestamp": "", 
	"last_saved": ""  
}

func save_game() -> bool:
	# Проверяем, есть ли уже timestamp (создано ли сохранение)
	if game_data["timestamp"] == "":
		# Первое сохранение - устанавливаем timestamp создания
		game_data["timestamp"] = Time.get_datetime_string_from_system()
	
	# Всегда обновляем время последнего сохранения
	game_data["last_saved"] = Time.get_datetime_string_from_system()
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	
	if file == null:
		var error = FileAccess.get_open_error()
		print("Ошибка сохранения: ", error_string(error))
		return false
	
	# Конвертируем в JSON
	var json_data = JSON.stringify(game_data, "\t")
	file.store_string(json_data)
	file.close()
	
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("Файл сохранения не найден: ", SAVE_FILE_PATH)
		return false
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	
	if file == null:
		var error = FileAccess.get_open_error()
		print("Ошибка загрузки: ", error_string(error))
		return false
	
	# Читаем JSON
	var json_text = file.get_as_text()
	file.close()
	
	# Парсим JSON
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		print("Ошибка парсинга JSON: ", json.get_error_message())
		return false
	
	# Копируем данные (timestamp сохраняется из файла)
	var loaded_data = json.get_data()
	game_data = loaded_data
	
	return true

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func delete_save() -> bool:
	if save_exists():
		DirAccess.remove_absolute(SAVE_FILE_PATH)
		print("Сохранение удалено")
		return true
	return false

func update_player_data(player_num: int, data: Dictionary):
	var player_key = "player" + str(player_num)
	
	if game_data.has(player_key):
		for key in data:
			game_data[player_key][key] = data[key]
	else:
		print("Ошибка: игрок ", player_num, " не найден в данных")

func get_player_data(player_num: int) -> Dictionary:
	var player_key = "player" + str(player_num)
	return game_data.get(player_key, {}).duplicate(true)

func set_difficulty(difficulty: int):
	game_data["difficulty"] = difficulty

func get_difficulty() -> int:
	return game_data.get("difficulty", 1)

func add_kill(player_num: int):
	var player_key = "player" + str(player_num)
	if game_data.has(player_key):
		game_data[player_key]["kills"] = game_data[player_key].get("kills", 0) + 1

func get_kills(player_num: int) -> int:
	var player_key = "player" + str(player_num)
	return game_data.get(player_key, {}).get("kills", 0)

func save_player_position(player_num: int, position: Vector2):
	var player_key = "player" + str(player_num)
	if game_data.has(player_key):
		game_data[player_key]["position_x"] = position.x
		game_data[player_key]["position_y"] = position.y

func get_player_position(player_num: int) -> Vector2:
	var player_key = "player" + str(player_num)
	var data = game_data.get(player_key, {})
	return Vector2(data.get("position_x", 0.0), data.get("position_y", 0.0))

# метод для создания новой игры
func new_game(difficulty: int = 1):
	"""
	Создает новое сохранение (сбрасывает timestamp)
	"""
	game_data = {
		"difficulty": difficulty,
		"time": 0.0,
		"player1": {
			"max_health": 100,
			"current_health": 100,
			"damage": 10,
			"kills": 0,
			"position_x": 0.0,
			"position_y": 0.0,
			"collected_items": []
		},
		"player2": {
			"max_health": 100,
			"current_health": 100,
			"damage": 10,
			"kills": 0,
			"position_x": 100.0,
			"position_y": 0.0,
			"collected_items": []
		},
		"timestamp": "",
		"last_saved": ""
	}
