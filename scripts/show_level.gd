extends CanvasLayer

@onready var level_label = $Label

func _ready():
	level_label.visible = true
	
	# Ждем 10 секунд
	await get_tree().create_timer(5.0).timeout
	
	# Плавно исчезает за 1 секунду
	var tween = create_tween()
	tween.tween_property(level_label, "modulate:a", 0.0, 1.0)
	await tween.finished
	level_label.visible = false
