extends Node

# PLayerData

signal change()

const MAX_HEALTH = 3
const MAX_AMMO = 500

var health: int = 3 setget set_health
var lives: int = 10 setget set_lives
var ammo: float = 0 setget set_ammo
var food_delivered: int = 0


func set_health(new_health: int) -> void:
	health = new_health
	emit_signal("change")


func set_lives(new_lives: int) -> void:
	lives = new_lives
	emit_signal("change")


func set_ammo(new_ammo: float) -> void:
	ammo = new_ammo
	emit_signal("change")


func heal(amount) -> void:
	if health < MAX_HEALTH:
		set_health(min(health + amount, MAX_HEALTH))


func gain_ammo(amount) -> void:
	set_ammo(min(ammo + amount, MAX_AMMO))


func reset():
	health = MAX_HEALTH
	lives = 10
	ammo = 0
	
