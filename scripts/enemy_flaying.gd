extends Enemy
class_name EnemyFlying

@export var vertical_speed: float = 80.0 
@export var follow_strength: float = 5.0
@export var preferred_attack_height: float = 30.0  # Предпочтительная высота для атаки

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if player and not is_attacking and not is_hurting:
		var target_y = player.global_position.y
		if can_attack and attack_area.get_overlapping_bodies().filter(func(b): return b.is_in_group("player")).size() > 0:
			target_y = player.global_position.y + preferred_attack_height
		
		var current_y = global_position.y
		var height_diff = target_y - current_y
		
		var vertical_velocity = height_diff * follow_strength
		vertical_velocity = clamp(vertical_velocity, -vertical_speed, vertical_speed)
		
		velocity.y = vertical_velocity
	
	super._physics_process(delta)
