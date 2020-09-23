extends Node


func _ready():
	pass

func _process(delta):
	if(Input.is_action_pressed("reset_scene")):
		get_tree().reload_current_scene()
