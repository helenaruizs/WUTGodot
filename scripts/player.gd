@tool
class_name Player
extends CharacterBody2D

## These notes can just be %references to the nodes in the tree, but this way, you always know if they aren't connected. 
@export_group("Nodes")
@export var input_node : INPUT			## Player's input node. 
@export var velocity_node : VELOCITY		## Player's velocity node. 
@export var animations : AnimatedSprite2D
@export var state_machine : STATE_MACHINE
@export var stamina_node : STAMINA


func _ready() -> void:
	# Initialize the state machine, passing a reference of the player to the states,
	# that way they can move and react accordingly
	state_machine.init()
	
func _unhandled_input(event: InputEvent) -> void:
	state_machine._unhandled_input(event)

func _physics_process(delta: float) -> void:
	state_machine._physics_process(delta)
	input_node.handleMoveInputs(delta)
	velocity_node.handleVelocity(delta)
	velocity_node.activateMove()

func _process(delta: float) -> void:
	state_machine._process(delta)
