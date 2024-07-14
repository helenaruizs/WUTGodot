extends Node

func get_movement_direction():
	return Input.get_axis("move_left", "move_right")

func wants_tojump() -> bool:
	return Input.is_action_just_pressed("jump")
