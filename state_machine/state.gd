class_name State
extends Node

@export
var animation_name: String
@export
var move_speed: float = 400

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

## Hold a reference to the parent so that it can be controlled by the state
var parent: CharacterBody2D
var animations: AnimatedSprite2D
@onready var move_component = $state_machine/move_component

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
	return move_component.get_movement_direction()

func get_jump() -> bool:
	if move_component.wants_tojump() && move_component.can_jump():
		return true
	else:
		return false

