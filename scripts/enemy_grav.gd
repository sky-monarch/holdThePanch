extends Enemy
class_name EnemyGrav

@export var gravity: float = 980.0
@export var max_fall_speed: float = 400.0

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
	else:
		velocity.y = 0
	super._physics_process(delta)
