extends Node2D


func _ready():
	get_node("Area2D").connect("body_entered", self, "_hit")
	

func _hit(body):
	_after_hit(body)
	queue_free()

func _after_hit(body):
	pass
