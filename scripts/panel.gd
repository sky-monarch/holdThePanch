extends Panel
@onready var panel = $"."

func _ready():
	# Начальное состояние - невидим
	panel.visible = false
	panel.modulate.a = 0.0
	
	# Ждем 5 секунд
	await get_tree().create_timer(1.0).timeout
	
	# Показываем и плавно появляемся
	panel.visible = true
	
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 1.0)
