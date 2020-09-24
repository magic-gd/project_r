extends "res://Objects/Collectible.gd"

export var type : String

func _ready():
	pass


func _after_pickup(body):
	body.add_item(type, self)
