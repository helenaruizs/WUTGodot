extends Node2D

@export_group("Node Links")
@export var staminaNode : STAMINA				## Grab the parent's input node.
# Called when the node enters the scene tree for the first time.
func _ready():
	print(staminaNode.stamina_max)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
