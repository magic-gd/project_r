extends Node
#
# AutoMover
# Moves a kinematic body
# Switches direction on collision or fall
#

export(bool) var enabled = true
export(float) var turnback_time = 2
export(int) var speed = 200
export(int) var gravity = 20

onready var body : KinematicBody2D = get_parent()
onready var turnback_timer : Timer = $TurnbackTimer

var motion = Vector2(speed,100)
var actual_motion : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	$TurnbackTimer.set_wait_time(turnback_time)

func _physics_process(delta):
	if !enabled:
		return
	
	if _check_turnback():
#		print(body.to_string() + " turning back")
		motion = Vector2(-motion.x, motion.y)
	
	actual_motion = body.move_and_slide(motion, Vector2.UP, false, 4, PI/4, false)


func _check_turnback() -> bool:
	if !turnback_timer.is_stopped():
		return false
	
	# Detect hover
	if !body.is_on_floor():
		turnback_timer.start()
		return true
	
	# Detect stop
	if actual_motion.length() < 0.001:
		turnback_timer.start()
		return true
	
	return false
