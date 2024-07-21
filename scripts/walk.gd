extends STATE

@export
var fall_state: STATE
@export
var idle_state: STATE
@export
var jump_state: STATE

func process_input(event: InputEvent) -> STATE:
	if get_jump() and parent.is_on_floor():
		return jump_state
	return null

func process_physics(delta: float) -> STATE:
	parent.velocity.y += gravity * delta
	
	var movement = get_movement_input() * move_speed
	
	if movement == 0:
		return idle_state
	
	parent.animations.flip_h = movement < 0
	parent.velocity.x = movement
	parent.move_and_slide()
	
	if !parent.is_on_floor():
		return fall_state
	return null
