extends CharacterBody2D

@export var speed: float = 400
@export var gravity: float = 900
@export var jump_force: float = 400
@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	
	# Обработка гравитации
	if not is_on_floor():
		velocity.y += gravity * delta

	# Горизонтальное движение
	var direction = Input.get_axis("left", "right")
	var isRun = Input.is_action_pressed("run")
	velocity.x = direction * speed
	if isRun:
		velocity.x *= 2
	

	# Обработка прыжка
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_force

	# Выбор анимации
	if not is_on_floor():
		anim.play("Jump")
	elif direction != 0:
		anim.flip_h = direction < 0
		if isRun:
			anim.play("Run")
		else:
			anim.play("Walk")
	else:
		anim.play("Idle")

	move_and_slide()

	
