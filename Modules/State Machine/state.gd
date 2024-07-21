class_name STATE
extends Node

# Reference to the state machine, to call its `transition_to()` method directly.
# That's one unorthodox detail of our state implementation, as it adds a dependency between the
# state and the state machine objects, but we found it to be most efficient for our needs.
# The state machine node will set it.
var state_machine = null

@export var animation_to_play : String

## Hold a reference to the parent so that it can be controlled by the state
var actor: CharacterBody2D
var animations: AnimatedSprite2D
var input_node : INPUT

func enter(_msg := {}) -> void:
	pass

func exit() -> void:
	pass

func process_input(event: InputEvent) -> void:
	pass

func process_frame(delta) -> void:
	pass

func process_physics(delta) -> void:
	pass

func playAnimation() -> void:
	actor.animations.play(animation_to_play)
