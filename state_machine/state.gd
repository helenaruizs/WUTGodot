class_name State
extends Node

@export
var animation_name: String

## Hold a reference to the parent so that it can be controlled by the state
@export var actor: CharacterBody2D
var animations: AnimatedSprite2D
@export var input_node : INPUT

func enter() -> void:
	animations.play(animation_name)

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null

func get_movement_input() -> float:
	return input_node.getMoveInput()

func get_jump() -> bool:
	if input_node.getJumpInputIn() && input_node.can_jump():
		return true
	else:
		return false

