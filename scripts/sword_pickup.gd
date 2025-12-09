extends Area2D

@export var min_damage_bonus: int = 2
@export var max_damage_bonus: int = 4
@export var frame_change_speed: float = 0.8
@export var rotation_speed: float = 8.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var damage_bonus: int = 0
var collected: bool = false
var total_frames: int = 0
var active_tweens = []

func _ready():
	damage_bonus = randi_range(min_damage_bonus, max_damage_bonus)
	
	# Проверяем наличие необходимых узлов
	if not anim_sprite:
		push_error("AnimatedSprite2D не найден!")
		queue_free()
		return
	
	initialize_sword_animation()
	start_float_animation()
	
	body_entered.connect(_on_body_entered)
	
	print("Создан меч: +", damage_bonus, " урона")

func initialize_sword_animation():
	if not anim_sprite.sprite_frames:
		push_error("SpriteFrames не назначен в AnimatedSprite2D!")
		return
	
	# Получаем первую доступную анимацию
	var anim_names = anim_sprite.sprite_frames.get_animation_names()
	if anim_names.size() == 0:
		push_error("Нет анимаций в SpriteFrames!")
		return
	
	var anim_name = anim_names[0]
	anim_sprite.animation = anim_name
	total_frames = anim_sprite.sprite_frames.get_frame_count(anim_name)
	
	if total_frames == 0:
		push_error("Анимация не имеет кадров!")
		return
	
	# Случайный начальный кадр
	anim_sprite.frame = randi() % total_frames
	anim_sprite.stop()
	
	# Запускаем анимации
	start_frame_cycle_animation()
	start_rotation_animation()

func start_frame_cycle_animation():
	var frame_tween = create_tween()
	active_tweens.append(frame_tween)
	frame_tween.set_loops()
	
	for i in range(total_frames):
		var target_frame = (anim_sprite.frame + i + 1) % total_frames
		var time = frame_change_speed * (i + 1)
		
		frame_tween.tween_callback(
			func(): 
				if is_instance_valid(anim_sprite) and not collected:
					anim_sprite.frame = target_frame
		).set_delay(time)

func start_rotation_animation():
	var rotation_tween = create_tween()
	active_tweens.append(rotation_tween)
	rotation_tween.set_loops()
	rotation_tween.tween_property(anim_sprite, "rotation_degrees", 360, rotation_speed).as_relative()

func start_float_animation():
	var float_tween = create_tween()
	active_tweens.append(float_tween)
	float_tween.set_loops()
	float_tween.set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(self, "position:y", position.y - 3.0, 0.8)
	float_tween.tween_property(self, "position:y", position.y, 0.8)

func _on_body_entered(body):
	if not collected and body.is_in_group("player"):
		collect_sword(body)

func collect_sword(player):
	collected = true
	
	# Отключаем коллизию
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	# Останавливаем все твины
	for tween in active_tweens:
		if tween and tween.is_valid():
			tween.kill()
	active_tweens.clear()
	
	# Применяем бонус
	if player.has_method("increase_damage"):
		player.increase_damage(damage_bonus)
	
	# Показываем текст бонуса
	show_bonus_text()
	
	# Анимация сбора
	play_collect_animation()

func show_bonus_text():
	# Создаем плавающий текст
	var bonus_text = Label.new()
	bonus_text.name = "BonusText"
	bonus_text.text = "+" + str(damage_bonus) + " DMG"
	bonus_text.modulate = Color.BLUE
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
	await get_tree().create_timer(10.0).timeout
	if is_instance_valid(bonus_text):
		bonus_text.queue_free()

func play_collect_animation():
	# Создаем эффект сбора
	var collect_tween = create_tween()
	active_tweens.append(collect_tween)
	
	collect_tween.set_parallel(true)
	
	# Подъем
	collect_tween.tween_property(self, "position:y", position.y - 60, 0.7).set_trans(Tween.TRANS_BACK)
	
	# Увеличение и вращение
	collect_tween.tween_property(anim_sprite, "scale", Vector2(1.5, 1.5), 0.7)
	collect_tween.tween_property(anim_sprite, "rotation_degrees", anim_sprite.rotation_degrees + 720, 0.7)
	
	# Исчезновение
	collect_tween.tween_property(anim_sprite, "modulate:a", 0.0, 0.7)
	
	# Свечение
	collect_tween.tween_property(anim_sprite, "modulate", Color(2, 2, 1), 0.2)
	collect_tween.chain().tween_property(anim_sprite, "modulate", Color.WHITE, 0.2)
	
	# Удаляем после анимации
	collect_tween.tween_callback(queue_free)
