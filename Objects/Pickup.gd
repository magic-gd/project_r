extends Node2D

export var magnetic = false
export var item: Resource = null
export var sprite_path: String = ""


func _ready():
	if sprite_path != "":
		$Sprite.texture = load(sprite_path)
	
	
