extends Button


func _ready():
	 self.connect("pressed", self, "_button_pressed")


func _button_pressed():
		get_parent().get_node("VictoryPanel").visible = false
		self.visible = false
		get_parent().get_node("CreditsPanel").visible = true
