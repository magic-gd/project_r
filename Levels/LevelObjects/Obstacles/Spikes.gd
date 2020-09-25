extends "res://Levels/LevelObjects/Obstacles/Obstacle.gd"


func _ready():
	pass

func _after_hit(body):
	body.die()
