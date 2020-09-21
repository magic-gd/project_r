extends Control

onready var grid = $GridContainer
onready var inventory_slots = grid.get_children()

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	Inventory.connect("change", self, "_on_Inventory_change")
	display_inventory()


func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()


func toggle_inventory() -> void:
	visible = !is_visible()
	get_tree().paused = visible


func clear() -> void:
	for child in grid.get_children():
		child.clear()



func display_inventory() -> void:
	clear()
	for i in range(0, inventory_slots.size()):
		if i >= Inventory.items.size():
			return
		else:
			inventory_slots[i].display_item(Inventory.items[i])


func _on_Inventory_change() -> void:
	display_inventory()
