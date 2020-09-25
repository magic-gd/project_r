extends StaticBody2D

onready var player = get_parent().get_node("Character")
onready var animationPlayer: AnimationPlayer = get_parent().get_node("TrapdoorAnimationPlayer")

func _ready():
	add_to_group("interaction")

func activate():
	if player.food_count > PlayerData.food_delivered:
		deliver_food(PlayerData.food_delivered - player.food_count)
	
	if player.food_count > 100:
		king_happy()
	else:
		king_mad()

func deliver_food(amount):
	pass

func king_happy():
	pass

func king_mad():
	animationPlayer.play("open_door")
	pass
