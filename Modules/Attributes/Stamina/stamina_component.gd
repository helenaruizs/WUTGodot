class_name STAMINA
extends Node

@export var stamina_max : float = 100.0

var stamina_total = stamina_max
var stamina_current = stamina_max

## These variables will need to be updated in relation to what each action should cost, including all modifiers that might exist
var stamina_regen = 0.05
var stamina_cost = 15.0

func hasEnoughStamina() -> bool:

	# If the player has any stamina, take the cost
	if stamina_current > 0:
		stamina_current -= stamina_cost
		if stamina_current < 0:
			stamina_current = 0
		return true
	else:
		return false

func regenStamina():
	if stamina_current < stamina_max:
		stamina_current += stamina_regen
