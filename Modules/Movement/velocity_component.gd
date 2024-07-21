class_name VELOCITY
extends Node

@onready var timer = $Timer

@export_group("Base Variables")
@export var SPEED : float = 100.0		## Actor's base speed.
@export var JUMP_VELOCITY : float = -300.0		## Actor's base jump speed.
@export var supress_stamina_cost : bool = true ## Movement doesn't cost stamina unless this box is checked.

@export_group("Modifier Variables")
@export var jump_height_force : float = 0.4

## Coyote time WIP
@export var coyote_time : float = 0.0
var coyote_jump = false

@export_group("Node Links")
@export var actor : CharacterBody2D 	## Parent node. 
@export var input_node : INPUT				## Grab the parent's input node.
@export var animations : AnimatedSprite2D

var currentSpeed : float = SPEED			## Local value of the speed after inputs.

## External forces
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") ## Get the gravity from the project settings to be synced with RigidBody nodes
var air_resistance = 0.1
var jump_lerp = 0.8

## Tracking Variables
var prevVelocity: Vector2 = Vector2.ZERO

#/
## Handle any velocity calculations. 
func handleVelocity(delta):
	prevVelocity = actor.velocity
	## Add the gravity and air resistance
	if not actor.is_on_floor():
		if coyote_time != 0:
			coyote_jump = true
			timer.wait_time = coyote_time
			timer.start()
			if _on_timer_timeout():
				coyote_jump = false
		if coyote_jump == false:
			actor.velocity.y += gravity * delta
			actor.velocity.x = lerp(prevVelocity.x, actor.velocity.x, air_resistance)	## Smooth the horizontal movement of the air state
			actor.velocity.y = lerp(prevVelocity.y, actor.velocity.y, jump_lerp)	## Smooth the vertical movement of the air state


	## Handle jump.
	if input_node.getJumpInputIn() and actor.is_on_floor():
		if !supress_stamina_cost:
			if actor.stamina_node.hasEnoughStamina():
				actor.velocity.y = JUMP_VELOCITY
		else:
			actor.velocity.y = JUMP_VELOCITY
	
	## Jump Height
	if input_node.getJumpInputOut() && actor.velocity.y < 0:
		actor.velocity.y *= jump_height_force

	
	## NOTE: If Sprinting is STANDARD for all users of this module, it could be moved here.
	
	## Get the input direction and handle the movement/deceleration.
	var direction = input_node.getMoveInput()
	if direction:
		actor.velocity.x = direction * currentSpeed
	else:
		actor.velocity.x = move_toward(actor.velocity.x, 0, SPEED)
		
	## Flip sprites
	if direction > 0:
		animations.flip_h = false
	elif direction < 0:
		animations.flip_h = true
#/
## Call any movement-related functions to initiate movement. 
func activateMove():
	actor.move_and_slide()

#/
## Modify the speed for any given set of modifiers. 
func calculateSpeed(addModifiers : Array[float], multModifiers : Array[float]):
	currentSpeed = SPEED
	
	## Add all multipliers first ##
	for modifier in addModifiers:
		currentSpeed += modifier
	
	## Multiply last (to make sure things like slows work properly) ##
	for modifier in multModifiers:
		currentSpeed *= modifier

func _on_timer_timeout():
	pass
