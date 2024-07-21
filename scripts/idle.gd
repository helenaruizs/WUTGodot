extends STATE

func enter() -> void:
	super()
	parent.velocity.x = 0

func process_input(event: InputEvent) -> STATE:
	if get_jump() and parent.is_on_floor():
		return jump_state
	if get_movement_input():
		return walk_state
	return null

func process_physics(delta) -> STATE:
	parent.velocity.y += gravity * delta
	parent.move_and_slide()
	
	if !parent.is_on_floor():
		return fall_state
	return null

func process_frame(delta):
	move_component.regen_stamina()
