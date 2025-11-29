extends Label
@onready var text_label = $"."

func _ready():
	# Начальное состояние - невидим
	text_label.visible = false
	text_label.modulate.a = 0.0
	
	# Ждем 5 секунд
	await get_tree().create_timer(0.5).timeout
	
	# Показываем и плавно появляемся
	text_label.visible = true
	
	var tween = create_tween()
	tween.tween_property(text_label, "modulate:a", 1.0, 1.0)
