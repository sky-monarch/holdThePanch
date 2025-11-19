extends Node

@export_category("Portal Settings")
@export var portal_scene: PackedScene
@export var level_portal_type: String = "blue"
@export var next_level_path: String = "res://Worlds/TileSets/world2.tscn"

func _ready():
	# Ждем пока все враги будут убиты
	check_enemies_periodically()

func check_enemies_periodically():
	while true:
		await get_tree().create_timer(1.0).timeout
		if is_all_enemies_defeated():
			spawn_portal()
			break

func is_all_enemies_defeated() -> bool:
	var enemies = get_tree().get_nodes_in_group("enemies")
	return enemies.size() == 0

# В PortalManager.gd
func spawn_portal():
	var portal = portal_scene.instantiate()
	portal.level_type = level_portal_type
	portal.next_level_scene = next_level_path
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Просто ставим портал на той же высоте что игрок, но выше
		portal.global_position = Vector2(
			player.global_position.x + 150,
			player.global_position.y - 100  # Выше игрока
		)
	else:
		portal.global_position = Vector2(500, 300)
	
	get_tree().current_scene.add_child(portal)
