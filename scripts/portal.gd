extends Area2D

@export_category("Level Settings")
@export_enum("Level1:blue", "Level2:orange", "Level3:purple", "Level4:green") 
var level_type: String = "blue"

@export_category("Scene Settings")
@export_file("*.tscn") var next_level_scene: String

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Соответствие типа уровня и анимации
var level_animations = {
	"blue": "Blue",
	"green": "Green", 
	"purple": "Purple",
	"orange": "Orange",
}

func _ready():
	# Устанавливаем анимацию в зависимости от типа уровня
	setup_portal_appearance()
	
	# Подключаем сигнал
	body_entered.connect(_on_body_entered)
	
	# Запускаем анимацию
	anim_sprite.play()

func setup_portal_appearance():
	# Устанавливаем нужную анимацию
	var animation_name = level_animations.get(level_type, "blue")
	anim_sprite.animation = animation_name

func _on_body_entered(body):
	if body.is_in_group("player"):
		start_teleport(body)

func start_teleport(player):
	# Блокируем повторный вход
	set_deferred("monitoring", false)
	
	# Проигрываем анимацию активации
	play_activation_animation()
	
	# Ждем завершения анимации
	await get_tree().create_timer(1.0).timeout
	
	# Переходим на следующий уровень
	load_next_level()

func play_activation_animation():
	# Увеличиваем масштаб для эффекта активации
	var tween = create_tween()
	tween.tween_property(anim_sprite, "scale", Vector2(1.3, 1.3), 0.5)
	tween.tween_property(anim_sprite, "scale", Vector2(1.0, 1.0), 0.5)

func load_next_level():
	if next_level_scene and ResourceLoader.exists(next_level_scene):
		get_tree().change_scene_to_file(next_level_scene)
	else:
		print("Ошибка: сцена не найдена")
