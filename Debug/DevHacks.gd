extends Node

func _input(event):
	if event.is_action_pressed("hack_ammo"):
		PlayerData.set_has_gun(true)
		PlayerData.gain_ammo(1000000)
		PlayerData.health = 10
