class_name PLAYER_INPUT
extends INPUT

@export var key_buffer_time : float = 10.0

func handleMoveInputs(delta):
	moveInput = Input.get_axis("move_left", "move_right")
	jumpInputIn = keyBuffer(Input.is_action_just_pressed("jump"), key_buffer_time)
	jumpInputOut = Input.is_action_just_released("jump")
	runInput = Input.is_action_pressed("run")
	attackInput = Input.is_action_pressed("ui_accept")
	deffendInput = Input.is_action_pressed("ui_cancel")

