extends "res://Objects/Collectible.gd"


export var type : String
export var timeout : int


func _ready():
	pass # Replace with function body.


func _after_pickup(body):
	body.add_powerup(type, timeout, self)
