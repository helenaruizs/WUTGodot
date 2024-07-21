extends STATE

# Upon entering the state, we set the Player node's velocity to zero.
func enter(_msg := {}) -> void:
	actor.velocity = Vector2.ZERO

func process_physics(delta):
	if !actor.is_on_floor():
		if actor.velocity.y < 0:
			state_machine.transition_to("Jump")
		if actor.velocity.y > 0:
			state_machine.transition_to("Fall")
	else:
		if actor.velocity.x != 0:
			state_machine.transition_to("Walk")

func process_frame(delta):
	actor.stamina_node.regenStamina()
	# If you have platforms that break when standing on them, you need that check for 
	# the character to fall.
	if !actor.is_on_floor():
		state_machine.transition_to("Fall")
		return
