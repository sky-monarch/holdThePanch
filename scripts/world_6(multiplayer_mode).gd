extends Node2D

@onready var player1 = $player
@onready var player2 = $player_two
@onready var camera = $MainCamera

@export_group("Основные настройки")
@export var min_zoom: float = 0.3
@export var max_zoom: float = 1.5
@export var smoothness: float = 4.0

@export_group("Дополнительно")
@export var enable_screen_shake: bool = false
@export var screen_shake_intensity: float = 5.0

var screen_shake_offset: Vector2 = Vector2.ZERO
var screen_shake_timer: float = 0.0

func _ready():
	if camera:
		camera.make_current()
	if SaveSystem.is_load:
		SaveSystem.load_game()
		var players = get_tree().get_nodes_in_group("player")
		players[0].load_save_data()
		players[1].load_save_data()
		SaveSystem.is_load = false
		
		

func _process(delta):
	if not camera or not player1 or not player2:
		return
	
	update_camera(delta)
	update_screen_shake(delta)

func update_camera(delta: float):
	var p1 = player1.global_position
	var p2 = player2.global_position
	
	var distance = p1.distance_to(p2)
	var center = (p1 + p2) / 2
	
	# Расчет зума
	var target_zoom = calculate_zoom(distance)
	
	# Плавное движение
	var target_position = center + screen_shake_offset
	camera.global_position = lerp(camera.global_position, target_position, delta * smoothness)
	camera.zoom = lerp(camera.zoom, Vector2(target_zoom, target_zoom), delta * smoothness)

func calculate_zoom(distance: float) -> float:
	# Плавная кривая отдаления
	var normalized_distance = clamp(distance / 1500.0, 0.0, 1.0)
	var target_zoom = lerp(max_zoom, min_zoom, normalized_distance)
	return clamp(target_zoom, min_zoom, max_zoom)

func update_screen_shake(delta: float):
	if screen_shake_timer > 0:
		screen_shake_timer -= delta
		screen_shake_offset = Vector2(
			randf_range(-screen_shake_intensity, screen_shake_intensity),
			randf_range(-screen_shake_intensity, screen_shake_intensity)
		)
	else:
		screen_shake_offset = Vector2.ZERO

# методы для управления камерой
func screen_shake(duration: float = 0.3):
	if enable_screen_shake:
		screen_shake_timer = duration

func set_camera_zoom(min_z: float, max_z: float):
	min_zoom = min_z
	max_zoom = max_z

func get_current_distance() -> float:
	if player1 and player2:
		return player1.global_position.distance_to(player2.global_position)
	return 0.0
