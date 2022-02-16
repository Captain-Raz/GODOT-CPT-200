extends KinematicBody2D

const UP = Vector2(0,-1)
export var GRAVITY = 20
export var MAXFALLSPEED = 200
export var MAXSPEED = 80
export var JUMPFORCE = 280
export var ACCEL = 10
export var FRICTION = 0.2

var motion = Vector2()
var facing_right = true
var state_machine
var attacks = ["Attack1","Attack2","Attack3"]

func _ready():
	state_machine = $AnimationTree.get("parameters/playback")

func get_input():
	#var current = state_machine.get_current_node()
	
	#Set limits for x-motion
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	
	#Set correct collision if ducking
	if Input.is_action_pressed("move_down"):
		$CollisionStand.disabled = true
		move_x()
	else:
		$CollisionStand.disabled = false
		
	#Attack animation
	if Input.is_action_pressed("attack"):
		attack()
	
	#Calculate motion and sprite direction based on left/right keys
	elif Input.is_action_pressed("move_right"):
		motion.x += ACCEL
		$Sprite.flip_h = false
		move_x()
	elif Input.is_action_pressed("move_left"):
		motion.x -= ACCEL
		$Sprite.flip_h = true
		move_x()
	#If neither is pressed and on the floor
	elif is_on_floor():
		#Slow down on the floor
		motion.x = lerp(motion.x, 0, FRICTION)
		move_x()

func _physics_process(_delta):
	get_input()
	#Establish gravity
	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	
	#Jump is pressed
	if is_on_floor():
		#Jump is pressed
		if Input.is_action_pressed("move_jump"):
			motion.y = -JUMPFORCE
			jump()
	else:
		if motion.y > 0:
			fall()

	#Re-evaluate motion using updated values
	motion = move_and_slide(motion,UP)
	
func hurt():
	state_machine.travel("Hurt")

func die():
	state_machine.travel("Die")
	set_physics_process(false)

func fall():
	state_machine.travel("Fall")
	
func jump():
	state_machine.travel("Jump")

func attack():
	#state_machine.travel(attacks[randi() % 2])
	state_machine.travel("Attack3")

func move_x():
	if is_on_floor():
		if Input.is_action_pressed("move_down"):
			state_machine.travel("Duck")
		elif Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right"):
			state_machine.travel("Run")
		else:
			state_machine.travel("Default")
	
func _on_SwordHit_area_entered(area):
		if area.is_in_group("hurtbox"):
			area.take_damage()
