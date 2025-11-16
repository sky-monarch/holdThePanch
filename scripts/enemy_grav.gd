extends Enemy
class_name EnemyGrav

@export var gravity: float = 980

func _physics_process(_delta: float) -> void:
		if not is_on_floor():
			velocity.y += gravity * _delta
		else:
			velocity.y = 0
		super._physics_process(_delta)
		
