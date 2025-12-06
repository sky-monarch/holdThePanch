extends OptionButton



func _on_item_selected(index: int) -> void:
	
	var options = [2, 1.5, 1, 0.5]
	var value = options[index]
	SaveSystem.set_difficulty(value)
	print (value)
