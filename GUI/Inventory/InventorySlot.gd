extends Label

func _ready():
	pass


func clear() -> void:
	text = "I am empty."


func display_item(item) -> void:
	text = "I am a " + item.name + "."
