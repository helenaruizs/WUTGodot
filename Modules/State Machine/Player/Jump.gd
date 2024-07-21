extends STATE

func process_physics(delta) -> void:
	if actor.is_on_floor():
		state_machine.transition_to("Idle")
	else:
		if actor.velocity.y > 0:
			state_machine.transition_to("Fall")
