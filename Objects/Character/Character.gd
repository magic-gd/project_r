extends KinematicBody2D
class_name PlayerController
# The player object

const UP = Vector2(0, -1)
const GRAVITY = 20
const MAX_SPEED = 350
const ACCELERATION = 120
const JUMP_HEIGHT = 700
const JUMP_BUFFER_SIZE = 5
const AIRJUMP_COUNT = 1

const DIRECTION_RIGHT = 1
const DIRECTION_LEFT = -1

export (int, 0, 1000) var inertia = 100

var direction = Vector2(DIRECTION_RIGHT, 1)
var motion = Vector2()
var coyote_jumpbuffer = 0
var idle: bool = true
var jumpsUsed: int = 0
var spriteBuffer: String = ""

var health = 3
var lives = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("hurtbox")
	add_to_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
#	print(motion)
	motion.y += GRAVITY
	spriteBuffer = ""
	if Input.is_action_pressed("move_right"):
		idle = false
		# Add speed up to max, but never take away speed
		motion.x = max(motion.x, min(motion.x+ACCELERATION, MAX_SPEED))
		$Sprite.flip_h = false
		spriteBuffer = "Run"
	elif Input.is_action_pressed("move_left"):
		idle = false
		motion.x = min(motion.x, max(motion.x-ACCELERATION, -MAX_SPEED))
		$Sprite.flip_h = true
		spriteBuffer = "Run"
	else:
		idle = true
		spriteBuffer = "Idle"
	
	if is_on_floor():
		coyote_jumpbuffer = JUMP_BUFFER_SIZE
		jumpsUsed = 0
		if idle:
			motion.x = lerp(motion.x, 0, 0.4)
	else:
		if idle:
			motion.x = lerp(motion.x, 0, 0.1)
		coyote_jumpbuffer -= 1
		
		if motion.y < 0 or (jumpsUsed > 0 and motion.y < 200):
			spriteBuffer = "Jump"
		else:
			spriteBuffer = "Fall"
	
#	print(jumpbuffer, " ", motion.y)
	if Input.is_action_just_pressed("jump"):
		_jump()
	
	motion = move_and_slide(motion, UP, false, 4, PI/4, false)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("movable_body"):
			collision.collider.apply_central_impulse(-collision.normal * inertia)

	_playSprite(spriteBuffer)
	


func take_damage(source: Vector2, strength: int):
	if $DamageAnimationPlayer.is_playing():
		# i-frames
		return
	$DamageAnimationPlayer.play("dmg_flash")
#	print("player took dmg. health: " + PlayerData.health as String)
	knockback(source, strength)
	PlayerData.health -= 1
	if PlayerData.health <= 0:
		die()


func die():
	PlayerData.lives -= 1
	if PlayerData.lives <= 0:
#		LevelChanger.game_over()
		pass
	else:
#		LevelChanger.restart_scene()
		pass


func knockback(source: Vector2, strength: int):
	var knockback : = source.direction_to(global_position)
#	setDebugMarker(source)
#	setDebugMarker(global_position)
	motion = knockback * strength * 100


func push_to(direction: Vector2):
	motion = motion + direction


func _jump():
	if jumpsUsed < AIRJUMP_COUNT:
		motion.y = -JUMP_HEIGHT if jumpsUsed == 0 else -JUMP_HEIGHT/2
		if coyote_jumpbuffer > 0:
			# Full jump (ground jump)
			motion.y = -JUMP_HEIGHT
			coyote_jumpbuffer = 0
		else:
			# Air jump
			motion.y = -JUMP_HEIGHT * 0.8
			jumpsUsed += 1



func _playSprite(spriteName: String):
#	$Sprite.play(spriteName)
	pass


func _setDebugMarker(pos: Vector2):
	var DebugMarker = load("res://Debug/DebugMarker.tscn")
	var debugMarker = DebugMarker.instance()
	var world = get_tree().current_scene
	world.add_child(debugMarker)
	debugMarker.global_position = pos
