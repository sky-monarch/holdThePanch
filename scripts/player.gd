extends CharacterBody2D

# Настройки персонажа
@export var speed: float = 400
@export var run_speed: float = 700
@export var gravity: float = 900
@export var jump_force: float = 400

# Узлы
@onready var anim = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var defend_area = $DefendArea

# Состояния
var is_attacking = false
var type_attack = 1
var is_defend = false


func _physics_process(delta: float) -> void:
	# Гравитация
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Горизонтальное движение 
	var direction = Input.get_axis("left", "right")
	var isRun = Input.is_action_pressed("run")

	if not is_attacking and not is_defend:  # Блокируем движение при атаке
		velocity.x = direction * speed
		if isRun:
			velocity.x = direction * run_speed
	else:
		velocity.x = 0

	# Прыжок
	if not is_attacking and not is_defend and is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_force

	# Анимации движения
	if not is_attacking and not is_defend:
		if not is_on_floor():
			anim.play("Jump")
		elif direction != 0:
			anim.flip_h = direction < 0
			anim.play("Run" if isRun else "Walk")
		else:
			anim.play("Idle")

	# Атака
	if not is_attacking and not is_defend and Input.is_action_just_pressed("attack"):
		attack()
	
	# Защита
	if not is_attacking and not is_defend and Input.is_action_just_pressed("defend"):
		defend()

	# Движение
	move_and_slide()

# Запуск атаки
func attack():
	is_attacking = true
	attack_area.monitoring = true

	match type_attack:
		1:
			type_attack = 2
			anim.play("Attack1")
		2:
			type_attack = 3
			anim.play("Attack2")
		_:
			type_attack = 1
			anim.play("Attack3")

	# Ждём фиксированное время атаки 
	await get_tree().create_timer(1).timeout

	is_attacking = false
	attack_area.monitoring = false

func defend():
	is_defend = true
	defend_area.monitoring = true
	anim.play("Defend")
	await get_tree().create_timer(1).timeout
	is_defend = false
	defend_area.monitoring = false
	
