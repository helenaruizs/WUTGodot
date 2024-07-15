class_name Player
extends CharacterBody2D

@onready var animations = $animations
@onready var state_machine = $state_machine
@onready var move_component = $move_component

# Stamina variables WIP
@export var stamina_max : float = 100.0
var stamina_total = stamina_max
var stamina_current = stamina_max
var stamina_regen = 0.05

func _ready() -> void:
	# Initialize the state machine, passing a reference of the player to the states,
	# that way they can move and react accordingly
	state_machine.init(self, animations, move_component)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)


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
