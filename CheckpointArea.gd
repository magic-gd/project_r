extends Node2D


func _ready():
	pass
	get_node("Area2D").connect("body_entered", self, "_player_enter")


func _player_enter(body):
	body.save_state(self.position)
