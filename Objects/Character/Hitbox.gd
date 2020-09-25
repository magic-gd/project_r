extends Area2D

func take_damage(source, strength):
	get_parent().take_damage(source, strength)
