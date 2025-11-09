extends CharacterBody2D

@export var speed: float = 100
@export var max_hp: int = 30
@export var damage: int = 10
@export var attack_cooldown: float = 5

var hp: int
var player: Node2D = null
var is_dead: bool = false
var can_attack: bool = false
var is_attacking: bool = false
var is_hurting: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
	hp = max_hp
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	attack_area.body_entered.connect(_on_attack_body_entered)
	attack_area.body_exited.connect(_on_attack_body_exited)
	anim.play("Idle")


func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	if is_hurting or is_attacking:
		move_and_slide()
		return

	if player:
		var dir = (player.global_position - global_position).normalized()
		velocity.x = dir.x * speed
		anim.flip_h = dir.x < 0

		if can_attack:
			velocity.x = 0
			_attack()
		else:
			anim.play("Walk")
	else:
		velocity.x = 0
		anim.play("Idle")

	move_and_slide()

func _on_detection_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_body_exited(body: Node) -> void:
	if body == player:
		player = null

func _on_attack_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		can_attack = true

func _on_attack_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		can_attack = false

func _attack() -> void:
	if is_attacking or is_dead or not player or is_hurting:
		return

	is_attacking = true
	anim.play("Attack")

	await get_tree().create_timer(0.8).timeout
	if can_attack and player and player.has_method("take_damage") and not player.is_defend:
		player.take_damage(damage)

	await anim.animation_finished
	is_attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func take_damage(amount: int) -> void:
	if is_dead or is_hurting:
		return
	hp -= amount
	is_hurting = true
	can_attack = false
	anim.play("Hurt")
	await anim.animation_finished
	if hp <= 0:
		die()
	await get_tree().create_timer(1).timeout
	is_hurting = false
	can_attack = true

func die() -> void:
	is_dead = true
	anim.play("Die")
	await anim.animation_finished
	queue_free()
