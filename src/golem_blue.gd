extends CharacterBody2D

@export var speed: float = 100
@export var max_hp: int = 30
@export var damage: int = 10
@export var attack_cooldown: float = 1.0  # секунды между атаками

var hp: int = max_hp
var player: Node2D = null
var is_dead: bool = false
var can_attack: bool = true
var is_attacking: bool = false

@onready var anim = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea


func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	attack_area.body_entered.connect(_on_attack_body_entered)


func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	# Если атакует — не двигается и не меняет анимацию
	if is_attacking:
		move_and_slide()
		return

	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
		anim.flip_h = direction.x < 0
		anim.play("Walk")
	else:
		velocity.x = 0
		anim.play("Idle")

	move_and_slide()


# Когда игрок входит в зону видимости
func _on_detection_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body


# Когда игрок выходит из зоны видимости
func _on_detection_body_exited(body: Node) -> void:
	if body == player:
		player = null


# Когда игрок входит в зону атаки
func _on_attack_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_attack(body)


# Логика атаки
func _attack(body: Node) -> void:
	if not can_attack or is_dead or is_attacking:
		return

	is_attacking = true
	can_attack = false
	anim.play("Attack")

	if body.has_method("take_damage"):
		body.take_damage(damage)

	# ждём, пока анимация атаки закончится
	await get_tree().create_timer(0.6).timeout
	is_attacking = false

	# ждём перезарядку
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


# Получение урона
func take_damage(amount: int) -> void:
	if is_dead:
		return

	hp -= amount
	anim.play("Hurt")
	await get_tree().create_timer(0.3).timeout

	if hp <= 0:
		die()


func die() -> void:
	is_dead = true
	anim.play("Die")
	await get_tree().create_timer(0.8).timeout
	queue_free()


# (необязательно, но удобно)
# Если хочешь, чтобы атака автоматически завершалась по окончанию анимации:
func _on_AnimatedSprite2D_animation_finished() -> void:
	if anim.animation == "Attack":
		is_attacking = false
