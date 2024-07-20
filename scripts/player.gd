@tool
class_name Player
extends CharacterBody2D

## These notes can just be %references to the nodes in the tree, but this way, you always know if they aren't connected. 
@export_group("Nodes")
@export var input_node : INPUT			## Player's input node. 
@export var velocity_node : VELOCITY		## Player's velocity node. 
@export var animations : AnimatedSprite2D
@export var state_machine : STATE_MACHINE

# Stamina variables WIP
@export var stamina_max : float = 100.0
var stamina_total = stamina_max
var stamina_current = stamina_max
var stamina_regen = 0.05

func _ready() -> void:
	# Initialize the state machine, passing a reference of the player to the states,
	# that way they can move and react accordingly
#	state_machine.init(self, animations, inputNode)
	pass
func _unhandled_input(event: InputEvent) -> void:
#	state_machine.process_input(event)
	pass
func _physics_process(delta: float) -> void:
	print(input_node.key_buffer_timer)
#	state_machine.process_physics(delta)
	input_node.handleMoveInputs(delta)
	velocity_node.handleVelocity(delta)
	velocity_node.activateMove()
func _process(delta: float) -> void:
#	state_machine.process_frame(delta)
	pass

## Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#
#@onready var animated_sprite = $AnimatedSprite2D
#
#
#func _physics_process(delta):
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y += gravity * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction = Input.get_axis("move_left", "move_right")
	#
	## Flip direction of animation
	#if direction > 0 :
		#animated_sprite.flip_h = false
	#elif direction < 0 :
		#animated_sprite.flip_h = true
	#
	## Play animations according to movement	
	#if is_on_floor():
		#if direction == 0 :
			#animated_sprite.play("idle")
		#else:
			#animated_sprite.play("walk")
	#else:
		#animated_sprite.play("jump")
	#
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
