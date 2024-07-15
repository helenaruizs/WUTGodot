extends Node

# Stamina WIP
@export var stamina_cost: float = 15.0
@onready var timer = $Timer

## Hold a reference to the parent so that it can be controlled by the script
@onready var player = $".." # this is no bueno in theory but I couldn't find a dynamic way to access the parent's variables 

func get_movement_direction():
	return Input.get_axis("move_left", "move_right")

func wants_tojump() -> bool:
	return Input.is_action_just_pressed("jump")


func can_jump() -> bool:
	print(player.stamina_current)

	# If the player has any stamina, take the cost
	if player.stamina_current > 0:
		player.stamina_current -= stamina_cost
		if player.stamina_current < 0:
			player.stamina_current = 0
		return true
	else:
		return false

func regen_stamina():
	if player.stamina_current < player.stamina_max:
		player.stamina_current += player.stamina_regen
