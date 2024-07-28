class_name TileMapPathfinding
extends TileMap

## For help check https://youtu.be/VJHrIP-_tHU?si=jB37pIhEcwXN-aon - that's the original tutorial source

const POINT_INDICATOR = preload("res://Environment/cell_indicator.tscn")

## Variables for kinds of possible tiles
var fall_tile : bool
var left_edge : bool
var right_edge : bool
var left_wall : bool
var right_wall : bool

var is_position_point : bool

var point_id : int

var point_position = Vector2.ZERO

func create_point_info(_point_id: int, _point_position: Vector2) -> Dictionary:
	var point_info = {
		"point_id": _point_id,
		"position": _point_position
	}
	return point_info

func addPoint(tile: Vector2i, check_position: Vector2i, node_type, is_empty: bool, color: Color = Color(1,1,1,1)):
	## If a tile exist above, it's not an edge
	if tileAboveExist(tile):
		return
	## If the tile to the left (X - 1) is empty
	if is_empty:
		if get_cell_source_id(COLLISION_LAYER, check_position) == CELL_IS_EMPTY:
			var tile_above = Vector2i(tile.x, tile.y - 1)
			var existing_point_id = tileAlreadyExistInGraph(tile_above)
			
			if existing_point_id == -1:
				var _point_id = _graph.get_available_point_id()
				var _point_position = map_to_local(tile_above)
				var _point_info = create_point_info(_point_id, _point_position)  # Create a new point information, and pass in the pointId
				_point_info.node_type = true
				_point_info_list.append(_point_info)
				_graph.add_point(_point_id, _point_position)
				addVisualPoint(tile_above, color)
			else:
				for _point_info in _point_info_list:
					if _point_info._point_id == existing_point_id:
						_point_info.node_type = true  # Flag that it's a left edge
						break
	if not is_empty:
		if get_cell_source_id(COLLISION_LAYER, check_position) != CELL_IS_EMPTY:
			var tile_above = Vector2i(tile.x, tile.y - 1)
			var existing_point_id = tileAlreadyExistInGraph(tile_above)
			
			if existing_point_id == -1:
				var _point_id = _graph.get_available_point_id()
				var _point_position = map_to_local(tile_above)
				var _point_info = create_point_info(_point_id, _point_position)  # Create a new point information, and pass in the pointId
				_point_info.node_type = true
				_point_info_list.append(_point_info)
				_graph.add_point(_point_id, _point_position)
				addVisualPoint(tile_above, color)
			else:
				for _point_info in _point_info_list:
					if _point_info._point_id == existing_point_id:
						_point_info.node_type = true  # Flag that it's a left edge
						break
				addVisualPoint(tile_above, color)

@export var show_debug_graph : bool = true

const COLLISION_LAYER : int = 0
const CELL_IS_EMPTY : int = -1
const MAX_TILE_FALL_SCAN_DEPTH : int = 500

var _graph : AStar2D = AStar2D.new()
var _used_tiles : Array[Vector2i]
var _graph_point : PackedScene


var _point_info_list = []

func _ready():
	_graph_point = POINT_INDICATOR
	_used_tiles = get_used_cells(COLLISION_LAYER)
	buildGraph()

func buildGraph() -> void:
	addGraphPoints()

func addGraphPoints() -> void:
	for tile in _used_tiles:
		addPoint(tile, Vector2i(tile.x - 1, tile.y), left_edge, true) # Left Edge point
		addPoint(tile, Vector2i(tile.x + 1, tile.y), right_edge, true) # Right Edge point
		addPoint(tile, Vector2i(tile.x - 1, tile.y - 1), left_wall, false) # Left Wall point
		addPoint(tile, Vector2i(tile.x + 1, tile.y - 1), right_wall, false) # Left Wall point

func tileAlreadyExistInGraph(tile: Vector2i) -> int:
	var local_position = map_to_local(tile)
	
	## If the graph contains points
	if _graph.get_point_count() > 0:
		var _point_id : int = _graph.get_closest_point(local_position)
		## If the points have the same local coordinates
		if _graph.get_point_position(_point_id) == local_position:
			return _point_id
	return -1

func addVisualPoint(_tile: Vector2, _color := Color("#000000"), _scale := 1.0):
	# If the graph should not be shown, return out of the method
	if not show_debug_graph:
		return

	# Instantiate a new visual point
	var visual_point = _graph_point.instantiate()

	# If a custom color has been passed in
	if _color != Color("#000000"):
		visual_point.modulate = _color  # Change the color of the visual point to the custom color
	
	# If a custom scale has been passed in, and it is within valid range
	if _scale != 1.0 and _scale > 0.1:
		visual_point.scale = Vector2(_scale, _scale)  # Update the visual point scale
	
	visual_point.position = map_to_local(_tile)  # Map the position of the visual point to local coordinates
	add_child(visual_point)  # Add the visual point as a child to the scene


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


