extends Button

func _ready():
	_check_save_on_scene_load()

func _check_save_on_scene_load():
	if SaveSystem.save_exists():
		visible = true
	else:
		visible = false
	
