extends Area2D

# InteractionArea

var _selection: Array = []

func _input(event):
	if event.is_action_pressed("interact"):
		activate()


func activate() -> void:
	if _selection.size() == 0:
		return
	
	_selection[0].get_parent().activate()



func _on_InteractionArea_area_entered(area):
	if area.is_in_group("interaction"):
		_selection.append(area)


func _on_InteractionArea_area_exited(area):
	if area.is_in_group("interaction"):
		_selection.erase(area)
