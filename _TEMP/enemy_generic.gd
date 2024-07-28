extends CharacterBody2D

@export var speed : float = 50.0
@export var jump_velocity : float = -300.0
@export var flip_node : Node2D
@export var ground_detector : Area2D
@export var jump_block : Area2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var ground_in_front : bool = true

# Moves right if facing right, and left if facing left 
# based on the root node's scale
@export var move_direction : Vector2 = Vector2.RIGHT :  
	set(new_direction):
		if(move_direction != new_direction):
			move_direction = new_direction
			flip_node.scale.x = new_direction.x
			
func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	# Check if there is no ground or if the character has reached a wall
	elif (not ground_detector.has_overlapping_bodies()
		or (is_on_wall())):
			# If the wall is too high to jump, flip directions
			if(jump_block.has_overlapping_bodies()):
				# Can't jump so try other direction
				move_direction *= -1
			# If facing a floor gap or a jumpable wall, jump
			else:
				jump()
		
	if move_direction:
		velocity.x = move_direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func jump():
	velocity.y += jump_velocity
