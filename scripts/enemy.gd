extends CharacterBody2D
class_name Enemy

@export var speed: float = 100
@export var max_hp: int = 30
@export var damage: int = 10
@export var attack_cooldown: float = 2.0
@export var sprite_direction = 1;

@export_category("Loot Settings")
@export var drop_potion_chance: float = 0.7
@export var drop_crystal_chance: float = 1  # 15% шанс
@export var potion_scene: PackedScene = preload("res://src/potion.tscn")
@export var health_crystal_scene: PackedScene = preload("res://src/health_crystal.tscn")


var hp: int
var player: Node2D = null
var is_dead: bool = false
var can_attack: bool = false
var is_attacking: bool = false
var is_hurting: bool = false
var can_take_damage = true
var tween = null

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var helth_bar = $HelthBar/FullHelthBar
@onready var empty_bar = $HelthBar/EmptyHelthBar
signal died

func _ready() -> void:
	hp = max_hp
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	attack_area.body_entered.connect(_on_attack_body_entered)
	attack_area.body_exited.connect(_on_attack_body_exited)
	add_to_group("enemies")

func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	if is_hurting or is_attacking:
		move_and_slide()
		return

	if player:
		var dir = (player.global_position - global_position).normalized()
		velocity.x = dir.x * speed
		anim.flip_h = dir.x*sprite_direction < 0
		var players_in_attack_range = attack_area.get_overlapping_bodies().filter(func(body): return body.is_in_group("player"))
		if can_attack and players_in_attack_range.size() > 0 and not is_attacking and not is_hurting:
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
	if is_attacking or is_dead or player == null or is_hurting:
		return

	is_attacking = true
	can_attack = false
	anim.play("Attack")

	await get_tree().create_timer(0.3).timeout
	
	if is_attacking and player and player.has_method("take_damage") and not player.is_defend:
		var bodies_in_range = attack_area.get_overlapping_bodies()
		for body_attack in bodies_in_range:
			if body_attack.is_in_group("player"):
				player.take_damage(damage)
				break 
	var animation_timeout = get_tree().create_timer(2.0)
	var animation_finished = anim.animation_finished
	
	@warning_ignore("standalone_expression")
	await animation_finished or animation_timeout.timeout
	is_attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func take_damage(amount: int) -> void:
	if is_dead or is_hurting or not can_take_damage:
		return
	
	hp -= amount
	update_helth_bar()
	is_hurting = true
	can_attack = false
	can_take_damage = false
	
	anim.play("Hurt")
	
	await anim.animation_finished
	
	if hp <= 0:
		die()
		return
	
	is_hurting = false
	await get_tree().create_timer(1.0).timeout
	can_take_damage = true
	can_attack = true

func die() -> void:
	is_dead = true
	can_attack = false
	can_take_damage = false
	
	anim.play("Die")
	await anim.animation_finished
	try_drop_loot()
	emit_signal("died")
	queue_free()
	
func update_helth_bar():
	var scale_hp = clamp(float(hp)/float(max_hp), 0.0, 1.0)/2
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(helth_bar, "scale:x", scale_hp, 0.2)
	tween.tween_property(empty_bar, "scale:x", scale_hp, 0.2)
	
func try_drop_loot():
	# Зелье
	if potion_scene and randf() <= drop_potion_chance:
		drop_item(potion_scene)
	
	# Кристалл здоровья
	if health_crystal_scene and randf() <= drop_crystal_chance:
		drop_item(health_crystal_scene)
		
func drop_item(item_scene: PackedScene):
	var item = item_scene.instantiate()
	
	# Случайное смещение от центра врага
	var offset = Vector2(
		randf_range(-15, 15),
		randf_range(-15, 15)
	)
	item.global_position = global_position + offset
	
	get_tree().current_scene.add_child(item)
