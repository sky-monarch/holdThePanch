extends CanvasLayer

@onready var level_label = $Label

func _ready():
	# Начальное состояние - невидим
	level_label.visible = false
	level_label.modulate.a = 0.0
	
	# Ждем 5 секунд
	await get_tree().create_timer(5.0).timeout
	
	# Показываем и плавно появляемся
	level_label.visible = true
	
	var tween = create_tween()
	tween.tween_property(level_label, "modulate:a", 1.0, 1.0)
