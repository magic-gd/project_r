extends Node2D

export var magnetic = false
export var active = true

func _ready():
	get_node("Area2D").connect("body_entered", self, "_pickup")
	

func _pickup(body):
	_after_pickup(body)
	deactivate()

func _after_pickup(body):
	pass

func deactivate():
	active = false
	$Sprite.hide()
	$Area2D/CollisionShape2D.disabled = true
	
func _after_deactivate():
	pass
	
func reactivate():
	active = true
	$Sprite.show()
	$Area2D/CollisionShape2D.disabled = false
	
func _after_reactivate():
	pass
