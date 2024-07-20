class_name INPUT
extends Node

var moveInput : float	## Left and Right movement float value.
var jumpInputIn : bool	## Jump key just pressed, false otherwise.
var jumpInputOut : bool	## Jump key just released, false otherwise.
var runInput : bool	## True for run, false otherwise.
var attackInput : bool	## True for attack, false otherwise.
var deffendInput : bool	## True for deffend/block, false otherwise.

var key_buffer_timer = 0
var key_buffered = 0

func keyBuffer(_key, _buffer_time) -> bool:
	if _key:
		key_buffer_timer = _buffer_time
	if key_buffer_timer > 0:
			key_buffered = 1
			key_buffer_timer -= 1
	else:
			key_buffered = 0
	if key_buffered:
		return true
	else:
		return false
	
## Return the Move Input float value
func getMoveInput() -> float:
	return moveInput

## Return the Jump Input In bool
func getJumpInputIn() -> bool:
	if keyBuffer(jumpInputIn, 12):
		return true
	else:
		return false
	
## Return the Jump Input Out bool
func getJumpInputOut() -> bool:
	return jumpInputOut

## Return the Jump Input bool
func getRunInput() -> bool:
	return runInput

## Return the Jump Input bool
func getAttackInput() -> bool:
	return attackInput

## Return the Jump Input bool
func getDeffendInput() -> bool:
	return deffendInput

## Base function to handle inputs
func handleMoveInputs(delta):
	pass
