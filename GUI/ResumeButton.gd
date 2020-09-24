extends "res://GUI/PlayButton.gd"


func _ready():
	pass

func _button_pressed():
		get_parent().visible = false
		get_tree().paused = false
