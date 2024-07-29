extends TileMap

@export var show_debug_graph: bool = true # If the graph points and lines should be drawn
@export var jump_distance: int = 5 # Distance between two tiles to count as a jump
@export var jump_height: int = 4 # Height between two tiles to connect a jump

const COLLISION_LAYER: int = 0 # The collision layer for the tiles
const CELL_IS_EMPTY: int = -1 # TileMap defines an empty space as -1
const MAX_TILE_FALL_SCAN_DEPTH: int = 500 # Max number of tiles to scan downwards for a solid tile

var astar_graph: AStar2D = AStar2D.new() # The A* graph
var used_tiles: Array = [] # The used tiles in the TileMap
var graphpoint: PackedScene # The graph point node to visualize path

var point_info_list: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load in the graph point packed scene
	graphpoint = preload("res://Environment/cell_indicator.tscn")
	print_debug("Loaded graph point scene.")
	# Get all the used tiles in the tile map
	used_tiles = get_used_cells(COLLISION_LAYER)
	print_debug("Found used tiles: %s" % used_tiles)
	# Build the graph
	build_graph()

func build_graph():
	add_graph_points() # Add all the graph points
	if not show_debug_graph:
		connect_points() # Connect the points

func get_point_info_at_position(position: Vector2) -> PointInfo:
	var new_info_point = PointInfo.new(-10000, position) # Create a new PointInfo with the position
	new_info_point.is_position_point = true # Mark it as a position point
	var tile = local_to_map(position) # Get the tile position

	# If a tile is found below
	if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x, tile.y + 1)) != CELL_IS_EMPTY:
		# If a tile exists to the left
		if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x - 1, tile.y)) != CELL_IS_EMPTY:
			new_info_point.is_left_wall = true # Flag that it's a left wall
		# If a tile exists to the right
		if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x + 1, tile.y)) != CELL_IS_EMPTY:
			new_info_point.is_right_wall = true # Flag that it's a right wall
		# If a tile doesn't exist one tile below to the left
		if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x - 1, tile.y + 1)) != CELL_IS_EMPTY:
			new_info_point.is_left_edge = true # Flag that it's a left edge
		# If a tile doesn't exist one tile below to the right
		if get_cell_source_id(COLLISION_LAYER, Vector2i(tile.x + 1, tile.y + 1)) != CELL_IS_EMPTY:
			new_info_point.is_right_edge = true # Flag that it's a right edge

	return new_info_point

func reverse_path_stack(path_stack: Array) -> Array:
	var reversed_stack = []
	for i in range(path_stack.size() - 1, -1, -1):
		reversed_stack.append(path_stack[i])
	return reversed_stack

func get_platform_2d_path(start_pos: Vector2, end_pos: Vector2) -> Array:
	var path_stack = []
	# Find the path between the start and end position
	var id_path = astar_graph.get_id_path(astar_graph.get_closest_point(start_pos), astar_graph.get_closest_point(end_pos))

	if id_path.size() <= 0:
		print_debug("No path found.")
		return path_stack # If the path has reached its goal, return the empty path stack

	var start_point = get_point_info_at_position(start_pos) # Create the point for the start position
	var end_point = get_point_info_at_position(end_pos) # Create the point for the end position
	var num_points_in_path = id_path.size() # Get number of points in the A* path

	# Loop through all the points in the path
	for i in range(num_points_in_path):
		var curr_point = get_info_point_by_point_id(id_path[i]) # Get the current point in the idPath

		if num_points_in_path == 1:
			continue # Skip the point in the A* path, the end point will be added as the only path point at the end.
		# If it's the first point in the A* path
		if i == 0 and num_points_in_path >= 2:
			var second_path_point = get_info_point_by_point_id(id_path[i + 1])
			if start_point.position.distance_to(second_path_point.position) < curr_point.position.distance_to(second_path_point.position):
				path_stack.append(start_point) # Add the start point to the path
				continue # Skip adding the current point and go to the next point in the path
		# If it's the last point in the path
		elif i == num_points_in_path - 1 and num_points_in_path >= 2:
			var penultimate_point = get_info_point_by_point_id(id_path[i - 1])
			if end_point.position.distance_to(penultimate_point.position) < curr_point.position.distance_to(penultimate_point.position):
				continue # Skip adding the last point to the path stack
			else:
				path_stack.append(curr_point) # Add the current point to the path stack
				break # Break out of the for loop

		path_stack.append(curr_point) # Add the current point
	path_stack.append(end_point) # Add the end point to the path
	print_debug("Generated path: %s" % path_stack)
	return reverse_path_stack(path_stack) # Return the path stack reversed

func get_info_point_by_point_id(point_id: int) -> PointInfo:
	for point_info in point_info_list:
		if point_info.point_id == point_id:
			return point_info
	return null

func draw_debug_line(to: Vector2, from: Vector2, color: Color):
	if show_debug_graph:
		draw_line(to, from, color) # Draw a line between the points with the given color

func add_graph_points():
	for tile in used_tiles:
		add_left_edge_point(tile)
		add_right_edge_point(tile)
		add_left_wall_point(tile)
		add_right_wall_point(tile)
		add_fall_point(tile)

func tile_already_exist_in_graph(tile: Vector2i) -> int:
	var local_pos = map_to_local(tile) # Map the position to screen coordinates

	if astar_graph.get_point_count() > 0:
		var point_id = astar_graph.get_closest_point(local_pos) # Find the closest point in the graph
		if astar_graph.get_point_position(point_id) == local_pos:
			return point_id # Return the point id, the tile already exists
	return -1 # If the node was not found, return -1

func add_visual_point(tile: Vector2i, color: Color = Color(), scale: float = 1.0):
	
	print_debug("TRIED TO INSTANTIAAAATTTEEE")
	if not show_debug_graph:
		return

	var visual_point = graphpoint.instantiate()
	if color:
		visual_point.modulate = color # Change the color of the visual point to the custom color
	if scale != 1.0 and scale > 0.1:
		visual_point.scale = Vector2(scale, scale) # Update the visual point scale
	visual_point.position = map_to_local(tile) # Map the position of the visual point to local coordinates
	add_child(visual_point) # Add the visual point as a child to the scene
	print_debug("Added visual point at: %s" % visual_point.position)

func get_point_info(tile: Vector2i) -> PointInfo:
	for point_info in point_info_list:
		if point_info.position == map_to_local(tile):
			return point_info
	return null

func _draw():
	if show_debug_graph:
		connect_points() # Connect the points & draw the graph and its connections

func connect_points():
	for p1 in point_info_list:
		connect_horizontal_points(p1)
		connect_jump_points(p1)
		connect_fall_point(p1)

func connect_fall_point(p1: PointInfo):
	if p1.is_left_edge or p1.is_right_edge:
		var tile_pos = local_to_map(p1.position)
		tile_pos.y += 1

		var fall_point = find_fall_point(tile_pos)
		if fall_point:
			var point_info = get_point_info(fall_point)
			var p2_map = local_to_map(p1.position)
			var p1_map = local_to_map(fall_point)
			if point_info:
				if not astar_graph.has_point(p1.point_id):
					astar_graph.add_point(p1.point_id, p1.position)
				if not astar_graph.has_point(point_info.point_id):
					astar_graph.add_point(point_info.point_id, point_info.position)
				astar_graph.connect_points(p1.point_id, point_info.point_id, 1.0) # Connect the fall point in the A* graph

func find_fall_point(start_pos: Vector2i) -> Vector2i:
	var pos = start_pos
	for i in range(MAX_TILE_FALL_SCAN_DEPTH):
		pos.y += 1 # Move one tile down
		if get_cell_source_id(COLLISION_LAYER, pos) != CELL_IS_EMPTY:
			return pos # Found a valid fall point
	return Vector2i() # If no valid fall point found, return an empty vector

func connect_horizontal_points(p1: PointInfo):
	var tile_pos = local_to_map(p1.position)
	var left_tile = Vector2i(tile_pos.x - 1, tile_pos.y)
	var right_tile = Vector2i(tile_pos.x + 1, tile_pos.y)

	if get_point_info(left_tile):
		if p1.is_left_edge or p1.is_left_wall:
			if not astar_graph.has_point(p1.point_id):
				astar_graph.add_point(p1.point_id, p1.position)
			if not astar_graph.has_point(get_point_info(left_tile).point_id):
				astar_graph.add_point(get_point_info(left_tile).point_id, get_point_info(left_tile).position)
			astar_graph.connect_points(p1.point_id, get_point_info(left_tile).point_id, 1.0) # Connect left edge/wall

	if get_point_info(right_tile):
		if p1.is_right_edge or p1.is_right_wall:
			if not astar_graph.has_point(p1.point_id):
				astar_graph.add_point(p1.point_id, p1.position)
			if not astar_graph.has_point(get_point_info(right_tile).point_id):
				astar_graph.add_point(get_point_info(right_tile).point_id, get_point_info(right_tile).position)
			astar_graph.connect_points(p1.point_id, get_point_info(right_tile).point_id, 1.0) # Connect right edge/wall

func connect_jump_points(p1: PointInfo):
	var tile_pos = local_to_map(p1.position)
	var jump_tile_pos = Vector2i(tile_pos.x, tile_pos.y - jump_height)
	
	if get_point_info(jump_tile_pos):
		if p1.is_left_edge or p1.is_right_edge:
			var point_info = get_point_info(jump_tile_pos)
			if point_info:
				if not astar_graph.has_point(p1.point_id):
					astar_graph.add_point(p1.point_id, p1.position)
				if not astar_graph.has_point(point_info.point_id):
					astar_graph.add_point(point_info.point_id, point_info.position)
				astar_graph.connect_points(p1.point_id, point_info.point_id, 1.0) # Connect jump point in the A* graph

func add_left_edge_point(tile: Vector2i):
	var point_id = tile_already_exist_in_graph(tile)
	var tile_above = Vector2i(tile.x, tile.y - 1)
	if point_id == -1:
		var new_point = PointInfo.new()
		new_point.is_left_edge = true
		new_point.position = map_to_local(tile)
		point_info_list.append(new_point)
		astar_graph.add_point(new_point.point_id, new_point.position) # Add the new point to the graph
		add_visual_point(tile_above)
		print_debug("Added left edge point: %s" % new_point.position)

func add_right_edge_point(tile: Vector2i):
	var point_id = tile_already_exist_in_graph(tile)
	if point_id == -1:
		var new_point = PointInfo.new()
		new_point.is_right_edge = true
		new_point.position = map_to_local(tile)
		point_info_list.append(new_point)
		astar_graph.add_point(new_point.point_id, new_point.position) # Add the new point to the graph
		print_debug("Added right edge point: %s" % new_point.position)

func add_left_wall_point(tile: Vector2i):
	var point_id = tile_already_exist_in_graph(tile)
	if point_id == -1:
		var new_point = PointInfo.new()
		new_point.is_left_wall = true
		new_point.position = map_to_local(tile)
		point_info_list.append(new_point)
		astar_graph.add_point(new_point.point_id, new_point.position) # Add the new point to the graph
		print_debug("Added left wall point: %s" % new_point.position)

func add_right_wall_point(tile: Vector2i):
	var point_id = tile_already_exist_in_graph(tile)
	if point_id == -1:
		var new_point = PointInfo.new()
		new_point.is_right_wall = true
		new_point.position = map_to_local(tile)
		point_info_list.append(new_point)
		astar_graph.add_point(new_point.point_id, new_point.position) # Add the new point to the graph
		print_debug("Added right wall point: %s" % new_point.position)

func add_fall_point(tile: Vector2i):
	var point_id = tile_already_exist_in_graph(tile)
	if point_id == -1:
		var new_point = PointInfo.new()
		new_point.is_fall_tile = true
		new_point.position = map_to_local(tile)
		point_info_list.append(new_point)
		astar_graph.add_point(new_point.point_id, new_point.position) # Add the new point to the graph
		print_debug("Added fall point: %s" % new_point.position)

# Helper function to print debug messages
func print_debug(message: String):
	print("[DEBUG] %s" % message)
