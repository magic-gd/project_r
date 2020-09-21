extends Node

# Inventory

signal change()

var coins: int = 0 setget set_coins
var items: Array = []


func _ready():
	var sword = load("res://Logic/Resources/Items/item_sword.tres")
	add_item(sword)


func set_coins(new_coins: int) -> void:
	coins = new_coins
	emit_signal("change")


func add_item(item) -> void:
	items.append(item)
	emit_signal("change")


func remove_item(item) -> void:
	items.erase(item)
	emit_signal("change")
