extends KinematicBody2D
class_name PlayerController
# The player object


class PlayerState:
	var food_count = 0
	var spawn = Vector2(0,0)

const UP = Vector2(0, -1)
const GRAVITY = 20
const MAX_BALLOON_SPEED = -500
const BALLOON_ACCELERATION = -10
const MAX_SPEED = 350
const ACCELERATION = 120
const JUMP_HEIGHT = 700
const JUMP_BUFFER_SIZE = 5
const AIRJUMP_COUNT = 1

const SPRITE_SIZE = Vector2(180, 180)

const DIRECTION_RIGHT = 1
const DIRECTION_LEFT = -1

const GAME_MODE_DEFAULT = 1
const GAME_MODE_BALLOON = 2
const GAME_MODE_FLAPPY = 3

var default_tex = preload("res://Assets/TempAssets/player_default.png")
var default_tex_offset = Vector2(0, 0)
var balloon_tex = preload("res://Assets/TempAssets/player_balloon.png")
var balloon_tex_offset = Vector2(-2, 17)
var wings_tex = preload("res://Assets/TempAssets/player_wings.png")
var wings_tex_offset = Vector2(0, 0)


export (int, 0, 1000) var inertia = 100

var direction = Vector2(DIRECTION_RIGHT, 1)
var motion = Vector2()
var coyote_jumpbuffer = 0
var idle: bool = true
var jumpsUsed: int = 0
var spriteBuffer: String = ""

var health = 3
var lives = 3
var food_count = 0
var powerup_timeout = 0
var powerup_time_since_pickup = 0
var last_state = PlayerState.new()
var items_since_last_spawn : Array
var powerups_since_last_spawn : Array

var game_mode = GAME_MODE_DEFAULT

var timeout_label = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("hurtbox")
	add_to_group("player")
	
	timeout_label = get_parent().get_node("CanvasLayer/HUD/TimeoutLabel")
	
	add_powerup("default", 0, null) # this is bad

func _process(delta):
	if(Input.is_action_pressed("reset_scene")):
		get_tree().reload_current_scene()
	elif(Input.is_action_pressed("respawn_player")):
		reset_state()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if(game_mode == GAME_MODE_DEFAULT):
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
		
	elif(game_mode == GAME_MODE_BALLOON):
		
		motion.y = max(MAX_BALLOON_SPEED, motion.y + BALLOON_ACCELERATION)
		spriteBuffer = ""
		if Input.is_action_pressed("move_right"):
			idle = false
			# Add speed up to max, but never take away speed
			motion.x = max(motion.x, min(motion.x+ACCELERATION, MAX_SPEED))
			$Sprite.flip_h = false
		elif Input.is_action_pressed("move_left"):
			idle = false
			motion.x = min(motion.x, max(motion.x-ACCELERATION, -MAX_SPEED))
			$Sprite.flip_h = true
		else:
			idle = true
			
		spriteBuffer = "Balloon"
	
	elif(game_mode == GAME_MODE_FLAPPY):
		
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
			if idle:
				motion.x = lerp(motion.x, 0, 0.4)
		else:
			if idle:
				motion.x = lerp(motion.x, 0, 0.1)
		
		coyote_jumpbuffer = 0
		jumpsUsed = 0
		
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
		elif collision.collider.is_in_group("obstacle"):
			die()

	_playSprite(spriteBuffer)
	
	_handle_powerups(delta)
	

func _handle_powerups(delta):
	if(powerup_timeout != 0):
		powerup_time_since_pickup += delta
		var remaining_time = powerup_timeout - powerup_time_since_pickup
		if(remaining_time < 0):
			add_powerup("default", 0, null)
		else:
			timeout_label.text = String(int(remaining_time))
		

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
	get_tree().reload_current_scene() # workaround
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


func add_powerup(type : String, timeout : int, powerup : Node):
	
	$BalloonCollisionShape2D2.disabled = true
	
	if(powerup != null):
		powerups_since_last_spawn.append(powerup)
	
	if(type == "default"):
		game_mode = GAME_MODE_DEFAULT
		$Sprite.texture = default_tex
		$Sprite.transform.origin = default_tex_offset
	elif(type == "balloon"):
		game_mode = GAME_MODE_BALLOON
		$Sprite.texture = balloon_tex
		$Sprite.transform.origin = balloon_tex_offset
		$BalloonCollisionShape2D2.disabled = false
		$PickUpSoundPlayer.play()
	elif(type == "wings"):
		game_mode = GAME_MODE_FLAPPY
		$Sprite.texture = wings_tex
		$Sprite.transform.origin = wings_tex_offset
		$PickUpSoundPlayer.play()
		
	if(timeout == 0):
		timeout_label.text = ""
		
	powerup_time_since_pickup = 0
		
	powerup_timeout = timeout
		

func add_item(type : String, item : Node):
	if(item != null):
		items_since_last_spawn.append(item)
	
	if(type == "apple"):
		food_count += 1
		
func save_state(spawn : Vector2):
	var current_state = PlayerState.new()
	current_state.food_count = food_count
	current_state.spawn = spawn
	last_state = current_state
	
	for item in items_since_last_spawn:
		item.queue_free()
		
	items_since_last_spawn.clear()

func reset_state():
	food_count = last_state.food_count
	position = last_state.spawn
	motion = Vector2(0, 0)
	
	for item in items_since_last_spawn:
		item.reactivate()
		
	items_since_last_spawn.clear()
	
	for powerup in powerups_since_last_spawn:
		powerup.reactivate()
		
	powerups_since_last_spawn.clear()
	
	add_powerup("default", 0, null)
	
