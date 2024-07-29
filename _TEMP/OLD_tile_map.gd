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

#region Point Info Dictionary functions
func create_point_info(_point_id: int, _point_position: Vector2) -> Dictionary:
	var point_info = {
		"point_id": _point_id,
		"position": _point_position,
		"left_edge": false,
		"right_edge": false,
		"left_wall": false,
		"right_wall": false,
		"fall_tile": null,
		"tile_scan": false
	}
	return point_info

# Function to get point info based on tile position
func get_point_info(tile: Vector2i) -> Dictionary:
	var local_position = map_to_local(tile)
	for point_info in _point_info_list:
		if point_info["position"] == local_position:
			return point_info
	return {}  # Return an empty dictionary if not found
#endregion

func tileAboveExist(tile: Vector2i) -> bool:
	if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x, tile.y - 1)) == CELL_IS_EMPTY:
		return false
	return true

func addPoint(tile: Vector2i, check_position: Vector2i, node_type: String, is_empty: bool, color: Color = Color(1,1,1,1)):
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
				_point_info[node_type] = true
				_graph.add_point(_point_id, _point_position)
				addVisualPoint(tile_above, color)
			else:
				for _point_info in _point_info_list:
					if _point_info["point_id"] == existing_point_id:
						_point_info[node_type] = true  # Flag that it's a left edge
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
					if _point_info["point_id"] == existing_point_id:
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
	print("Initial _point_info_list:", _point_info_list)

func buildGraph() -> void:
	addGraphPoints()

func addGraphPoints() -> void:
	for tile in _used_tiles:
		addPoint(tile, Vector2i(tile.x - 1, tile.y), "left_edge", true) # Left Edge point
		addPoint(tile, Vector2i(tile.x + 1, tile.y), "right_edge", true) # Right Edge point
		addPoint(tile, Vector2i(tile.x - 1, tile.y - 1), "left_wall", false) # Left Wall point
		addPoint(tile, Vector2i(tile.x + 1, tile.y - 1), "right_wall", false) # Left Wall point
		add_fall_point(tile)

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

#region Tile Fall Points
func getStartScanTileForFallPoint(tile: Vector2i) -> Dictionary:
	var tile_above = Vector2i(tile)
	var point = get_point_info(tile_above)
	
	if not point:  # If point is an empty dictionary or null
		print("No point info found for tile: %s" % tile_above)
		return {}  # Return an empty dictionary
	
	var tile_scan = Vector2i()
	
	if point.has("left_edge") and point["left_edge"]:
		tile_scan = Vector2i(tile.x - 1, tile.y - 1)  # Start scanning left
		print("Start scan at left edge: %s" % tile_scan)
		return {"tile_scan": tile_scan}
		
	elif point.has("right_edge") and point["right_edge"]:
		tile_scan = Vector2i(tile.x + 1, tile.y - 1)  # Start scanning right
		print("Start scan at right edge: %s" % tile_scan)
		return {"tile_scan": tile_scan}
	
	print("No valid edge found for tile: %s" % tile_above)
	return {}  # Return an empty dictionary if no valid start position found



func findFallPoint(tile: Vector2) -> Dictionary:
	var scan = getStartScanTileForFallPoint(Vector2i(tile.x, tile.y))  # Get the start scan tile position
	if not scan:
		
		print("No start scan tile found for fall point.")
		return {}  # If it wasn't found, return an empty dictionary

	var tile_scan = scan["tile_scan"]  # Extract tile_scan from the dictionary
	var fall_tile = null  # Initialize fall_tile to null

	# Loop to look for a solid tile
	for i in range(MAX_TILE_FALL_SCAN_DEPTH):
		# If the tile cell below is solid
		if get_cell_source_id(COLLISION_LAYER, Vector2i(tile_scan.x, tile_scan.y + 1)) != CELL_IS_EMPTY:
			fall_tile = tile_scan  # The fall tile was found
			break  # Break out of the loop
		# If a solid tile was not found, scan the next tile below the current one
		tile_scan.y += 1

	if fall_tile != null:
		print("Found fall tile: %s" % fall_tile)
		return {"fall_tile": fall_tile}  # Return the fall tile result
	else:
		print("No fall tile found.")
		return {}  # Return an empty dictionary if no fall tile was found

func add_fall_point(tile: Vector2i) -> void:
	var fall_tile = findFallPoint(Vector2(tile.x, tile.y))  # Find the fall tile point
	if not fall_tile:
		return  # If the fall tile was not found, return out of the method
	
	var fall_tile_local = map_to_local(fall_tile["fall_tile"])  # Get the local coordinates for the fall tile

	var existing_point_id = tileAlreadyExistInGraph(fall_tile["fall_tile"])  # Check if the point already has been added

	# If the tile doesn't exist in the graph already
	if existing_point_id == -1:
		var point_id = _graph.get_available_point_id()  # Get the next available point id
		var point_info = {"point_id": point_id, "position": fall_tile_local, "fall_tile": true}  # Create point information
		_point_info_list.append(point_info)  # Add the tile to the point info list
		_graph.add_point(point_id, fall_tile_local)  # Add the point to the Astar graph, in local coordinates
		addVisualPoint(fall_tile["fall_tile"], Color(1, 0.35, 0.1, 1), 0.35)  # Add the point visually to the map (if show_debug_graph is true)
	else:
		for point_info in _point_info_list:
			if point_info["point_id"] == existing_point_id:
				point_info["fall_tile"] = true  # Flag that it's a fall point
				break
		addVisualPoint(fall_tile["fall_tile"], Color("#ef7d57"), 0.30)  # Add the point visually to the map (if show_debug_graph is true)


#endregion

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


