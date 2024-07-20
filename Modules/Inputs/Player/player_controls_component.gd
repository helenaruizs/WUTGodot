class_name PLAYER_INPUT
extends INPUT

func handleMoveInputs(delta):
	moveInput = Input.get_axis("move_left", "move_right")
	jumpInputIn = Input.is_action_just_pressed("jump")
	jumpInputOut = Input.is_action_just_released("jump")
	runInput = Input.is_action_pressed("run")
	attackInput = Input.is_action_pressed("ui_accept")
	deffendInput = Input.is_action_pressed("ui_cancel")
