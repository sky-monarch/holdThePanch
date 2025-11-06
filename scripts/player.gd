extends CharacterBody2D

var speed = 400
@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		var direction = Input.get_axis("left","right")
		velocity.x = speed * direction
		anim.flip_h = direction < 0
		anim.play("Walk")
	else:
		anim.play("Idle")
		velocity.x = 0
	move_and_slide()
	
