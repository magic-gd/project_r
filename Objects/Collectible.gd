extends Node2D

export var magnetic = false
export var item: Resource = null


func _ready():
	get_node("Area2D").connect("body_entered", self, "_pickup")
	

func _pickup(body):
	_after_pickup(body)
	queue_free()

func _after_pickup(body):
	pass
