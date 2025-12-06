extends Area2D

@export var min_health_bonus: int = 5
@export var max_health_bonus: int = 15

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var health_bonus: int = 0
var collected: bool = false

func _ready():
	health_bonus = randi_range(min_health_bonus, max_health_bonus)
	
	# Запускаем анимацию idle
	if anim_sprite:
		anim_sprite.play("Idle")
	
	# Легкая плавающая анимация
	start_float_animation()
	
	# Подключаем сигнал
	body_entered.connect(_on_body_entered)

func start_float_animation():
	# Простая плавающая анимация поверх основной
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "position:y", position.y - 2, 0.5)
	tween.tween_property(self, "position:y", position.y, 0.5)

func _on_body_entered(body):
	if not collected and body.is_in_group("player"):
		collect_crystal(body)

func collect_crystal(player):
	collected = true
	set_deferred("monitoring", false)
	
	# Применяем бонус к игроку
	if player.has_method("increase_max_health"):
		player.increase_max_health(health_bonus)
	
	show_bonus_text()
	
	# Анимация сбора
	play_collect_animation()

func show_bonus_text():
	# Создаем плавающий текст
	var bonus_text = Label.new()
	bonus_text.name = "BonusText"
	bonus_text.text = "+" + str(health_bonus) + " HP"
	bonus_text.modulate = Color.GREEN
	bonus_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var custom_font = load("res://resourse/data for the main menu/ZenterSPDemo-Black.otf")
	if custom_font:
		bonus_text.add_theme_font_override("font", custom_font)
		bonus_text.add_theme_font_size_override("font_size", 12)
	
	bonus_text.add_theme_color_override("font_outline_color", Color.BLACK)
	bonus_text.add_theme_constant_override("outline_size", 2)
	
	# Добавляем к кристаллу
	add_child(bonus_text)
	bonus_text.position = Vector2(0, -20)
	
	# ПРОСТО УДАЛЯЕМ ЧЕРЕЗ 0.8 СЕКУНД
	await get_tree().create_timer(0.8).timeout
	if is_instance_valid(bonus_text):
		bonus_text.queue_free()
		

func play_collect_animation():
	# Останавливаем все твины
	var tweens = get_tree().get_processed_tweens()
	for tween in tweens:
		if tween.is_valid():
			tween.kill()
	
	# Останавливаем анимацию idle
	if anim_sprite:
		anim_sprite.stop()
	
	# Анимация сбора: подъем + вращение + исчезновение
	var tween = create_tween()
	tween.parallel().tween_property(self, "position:y", position.y - 30, 0.5)
	tween.parallel().tween_property(anim_sprite, "rotation", anim_sprite.rotation + PI, 0.5)
	tween.parallel().tween_property(anim_sprite, "scale", Vector2(0.5, 0.5), 0.5)
	tween.parallel().tween_property(anim_sprite, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
