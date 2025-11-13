extends Camera2D

@export var target: Node2D
@export var move_speed: float = 5.0

func _process(delta):
	if target:
		# Плавное следование за целью
		global_position = global_position.lerp(target.global_position, move_speed * delta)
		
		# Или мгновенное следование
		# global_position = target.global_position
