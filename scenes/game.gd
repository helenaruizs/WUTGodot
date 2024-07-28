extends Node2D
#
#const CELL_INDICATOR = preload("res://Environment/cell_indicator.tscn")
#
##@onready var tile_map = %TileMap
#var tile_map
#var graph
#
#var cell_size = 32
#
#func _ready():
	#graph = AStar2D.new()
	#tile_map = find_parent("Game").find_child("TileMap")
	#createMap()
#
#func createMap():
	#var cells = tile_map.get_used_cells()
	#
	#for cell in cells:
		#var above = Vector2(cell[0], cell[1] - 1)
		#
		#if !(above in cells):
			#var cell_indicator = CELL_INDICATOR.instantiate()
			#cell_indicator.position = tile_map.map_to_local(above) + Vector2(cell_size/2, cell_size/2)
			#add_child(cell_indicator)
			##call_deferred("add_child",cell_indicator)
			#pass
