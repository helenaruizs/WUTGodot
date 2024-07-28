extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

## WIP follow player logic
var max_distance : float = 100.0 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

## Tracking Variables
var prevVelocity: Vector2 = Vector2.ZERO
var newVelocity: Vector2 = Vector2.ZERO

func _physics_process(delta):
	## Move towards the player
	if global_position.distance_to(Global.player_position) > max_distance:
		prevVelocity = velocity
		newVelocity = global_position.direction_to(Global.player_position) * SPEED
		velocity = lerp(prevVelocity, newVelocity, 0.01)
		move_and_slide()
		
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y += gravity * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction = Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
