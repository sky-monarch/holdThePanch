extends Button
@onready var text_button = $"."
func _ready():
	# Начальное состояние - невидим
	text_button.visible = false
	text_button.modulate.a = 0.0
	
	# Ждем 5 секунд
	await get_tree().create_timer(2.5).timeout
	
	# Показываем и плавно появляемся
	text_button.visible = true
	
	var tween = create_tween()
	tween.tween_property(text_button, "modulate:a", 1.0, 1.0)
