class_name STATE_MACHINE
extends Node

# Emitted when transitioning to a new state.
signal transitioned(STATE)

@export var starting_state: STATE ## Hook up to the initial state (usually idle)
@onready var state = starting_state

@export var actor : CharacterBody2D

# Initialize the state machine by giving each child state a reference to the
# parent object it belongs to and enter the default starting_state.
func init() -> void:
	for child in get_children():
		child.actor = actor
		child.animations = actor.animations
		child.input_node = actor.input_node
		child.state_machine = self
		
	# Initialize to the default state
	state.enter()

func _unhandled_input(event) -> void:
	state.process_input(event)

func _process(delta) -> void:
	state.playAnimation()
	state.process_frame(delta)

func _physics_process(delta) -> void:
	state.process_physics(delta)

# Change to the new state by first calling any exit logic on the current state.
func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	if !has_node(target_state_name):
		print("State Name Doesn't Exist!")
		return
	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	emit_signal("transitioned", state.name)

