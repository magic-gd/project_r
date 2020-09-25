extends StaticBody2D

onready var player = get_parent().get_node("Character")
onready var animationPlayer: AnimationPlayer = get_parent().get_node("TrapdoorAnimationPlayer")

func _ready():
	add_to_group("interaction")

func activate():
	if player.food_count > PlayerData.food_delivered:
		deliver_food(PlayerData.food_delivered - player.food_count)
	
	if player.food_count >= 80:
		king_happy()
	else:
		king_mad()

func deliver_food(amount):
	pass

func king_happy():
	get_parent().get_node("SpeechBubble").win()
	$WinTimer.start()
	pass

func king_mad():
	animationPlayer.play("open_door")
	pass


func _on_WinTimer_timeout():
	get_tree().change_scene("res://GUI/EndScreen.tscn")
