extends CharacterBody2D

@export var speed: float = 400
@export var run_speed: float = 700
@export var gravity: float = 900
@export var jump_force: float = -500
@export var base_damage: int = 10
@export var base_max_hp: int = 100
var max_hp: int
var hp: int
var damage: int
var kills = 0
@export var change_crit_damade = 0.3
@export var crit_damage = 2

var is_attacking: bool = false
var is_defend: bool = false
var is_hurting: bool = false
var type_attack: int = 1
var tween = null
var is_died = false

@onready var anim = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var defend_area = $DefendArea
@onready var helth_bar = $HelthBar/FullHelthBar
@onready var empty_bar = $HelthBar/EmptyHelthBar

func _ready():
	max_hp = base_max_hp
	hp = max_hp
	damage = base_damage
	update_helth_bar()

func _physics_process(delta: float) -> void:
	if is_died:
		move_and_slide()
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if is_attacking or is_defend or is_hurting:
		velocity.x = 0
	else:
		var direction = Input.get_axis("left_two", "right_two")
		var is_running = Input.is_action_pressed("run_two")
		velocity.x = direction * (run_speed if is_running else speed)

		if Input.is_action_just_pressed("jump_two") and is_on_floor():
			velocity.y = jump_force

		if not is_on_floor():
			anim.play("Jump")
		elif direction != 0:
			anim.flip_h = direction < 0
			anim.play("Run" if is_running else "Walk")
		else:
			anim.play("Idle")

	if Input.is_action_just_pressed("attack_two") and not (is_attacking or is_defend or is_hurting):
		attack()

	if Input.is_action_just_pressed("defend_two") and not (is_attacking or is_hurting):
		defend()

	move_and_slide()


func attack():
	if is_died:
		return
	is_attacking = true
	is_defend = true
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

	await get_tree().create_timer(1.0).timeout
	is_attacking = false
	attack_area.monitoring = false 
	is_defend = false

func defend():
	is_defend = true
	defend_area.monitoring = true
	anim.play("Defend")
	await get_tree().create_timer(1.0).timeout
	is_defend = false
	defend_area.monitoring = false

func take_damage(_damage):
	if is_hurting or is_defend or is_died:
		return

	is_hurting = true
	hp -= _damage
	update_helth_bar()
	anim.play("Hurt")
	if hp <= 0:
		die()
	await get_tree().create_timer(0.5).timeout
	is_hurting = false




func _on_attack_area_body_entered(body: Node2D):
	if body.has_method("take_damage") and not body.is_in_group("player"):
		if randf() < change_crit_damade:
			body.take_damage(damage * crit_damage)
		else:
			body.take_damage(damage)
		


func die():
	is_died = true
	anim.play("Died")
	await anim.animation_finished
	await get_tree().create_timer(2).timeout
	queue_free()
	
func update_helth_bar():
	var scale_hp = clamp(float(hp)/float(max_hp), 0.0, 1.0)/2
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(helth_bar, "scale:x", scale_hp, 0.2)
	tween.tween_property(empty_bar, "scale:x", scale_hp, 0.2)
	
func heal(amount: int):
	hp = min(hp + amount, max_hp)
	update_helth_bar()
	
	
func increase_max_health(amount: int):
	# Увеличиваем максимальное здоровье
	var old_max_hp = max_hp
	max_hp += amount
	
	# Также восстанавливаем текущее здоровье пропорционально
	var health_percentage = float(hp) / float(old_max_hp)
	hp = int(max_hp * health_percentage) + amount
	
	# Обновляем UI
	update_helth_bar()
	
func increase_damage(_damage_bonus):
	damage+=_damage_bonus
func save_data():
	@warning_ignore("unused_variable")
	var data =  {
		"max_health": max_hp,
		"current_health": hp,
		"damage": damage,
		"kills": kills,
		"position_x": global_position.x,
		"position_y": global_position.y,
	}
	SaveSystem.update_player_data(2, data)

func load_save_data(data: Dictionary):
	if data.is_empty() and Engine.has_singleton("SaveSystem"):
		# Автоматическая загрузка из SaveSystem
		data = SaveSystem.get_player_data(2)
	# Загружаем данные
	max_hp = data.get("max_health", max_hp)
	hp = data.get("current_health", hp)
	damage = data.get("damage", damage)
	kills = data.get("kills", kills)
	# Позиция
	var pos_x = data.get("position_x", global_position.x)
	var pos_y = data.get("position_y", global_position.y)
	global_position = Vector2(pos_x, pos_y)
