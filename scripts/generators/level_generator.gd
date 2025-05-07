extends Node
class_name LevelGenerator

# Configuration – you can conveniently store data about segment size, level dimensions, etc.
var segment_size = Vector2i(8, 8) # can be changed at initialization
var map_size     = Vector2i(64, 64) # example, can be set at startup

# Here you can specify coordinates for different tile types (to be filled later)
var tile_definitions = {
	"corner": Vector2i(0, 0),
	"side": Vector2i(1, 0),
	"center": Vector2i(2, 0),
	"transition": Vector2i(3, 0)
}

# To store data about already occupied positions – the tile occupancy grid
var occupancy_grid = []
# Data about generated rooms and corridors
var rooms     = []
var corridors = []

func _init():
	# Initialize occupancy_grid
	occupancy_grid.resize(map_size.y)
	for i in range(map_size.y):
		occupancy_grid[i] = []
		occupancy_grid[i].resize(map_size.x)
		for j in range(map_size.x):
			occupancy_grid[i][j] = false

func generate_test():
	# Example: generate one 8x8 room and from it create a 2x4 corridor
	# Then attempt to make a complex L-shaped room, 2x2, etc.
	# This is just example logic.

	# First, generate a standard room (single segment)
	var room_pos   = Vector2i(10, 10)
	var room_shape = [[true]] # Single segment – just one block
	place_room(room_pos, room_shape)

	# Long (horizontal) room consisting of 2 segments
	var long_room_pos   = Vector2i(30, 10)
	var long_room_shape = [[true, true]]
	place_room(long_room_pos, long_room_shape)

	# L-shaped room: 2x2 where one corner is missing
	var l_room_pos   = Vector2i(10, 30)
	var l_room_shape = [
		[true, true],
		[true, false]
	]
	place_room(l_room_pos, l_room_shape)

	# Corridor 2x4: for testing, connect the first room to the second
	# Let's assume the corridor goes horizontally
	var corridor_start = Vector2i(room_pos.x + segment_size.x/2, room_pos.y + segment_size.y) # from the middle of the bottom wall of the first room
	var corridor_dir   = Vector2i(0, 1) # downward
	place_corridor(corridor_start, corridor_dir, 4) # length 4 tiles, width fixed at 2

	# And so on. You can generate more complex structures.
	# After generation, we have populated arrays rooms and corridors,
	# as well as occupancy_grid marking occupied positions.

	# Next, you can iterate through rooms and corridors to see which tiles are occupied
	# and place the corresponding tiles (corner, side, center, transition). For example:
	for y in range(map_size.y):
		for x in range(map_size.x):
			if occupancy_grid[y][x] == true:
				# Determine the tile type (corner, side, etc.)
				# This can be done by analyzing neighbors (whether there are other room or corridor tiles adjacent).
				var tile_type = determine_tile_type(x, y)

# tile_type will return something like "corner", "side", "center", or "transition".
# Then set the tile in TileMap:
# tilemap.set_cell(0, Vector2i(x,y), tile_definitions[tile_type])

# At this point, we have a test generation.

func place_room(start_pos: Vector2i, shape: Array):
	# shape is a 2D bool array representing the room shape in segments
	# For example [[true,true],[true,false]]
	# Each true represents an 8x8 segment.

	var room_data = {
		"position": start_pos,
		"shape": shape
	}
	rooms.append(room_data)

	# Lay out segments on the map
	for row_i in range(shape.size()):
		for col_i in range(shape[row_i].size()):
			if shape[row_i][col_i]:
				var seg_start_x = start_pos.x + col_i * segment_size.x
				var seg_start_y = start_pos.y + row_i * segment_size.y
				mark_room_segment(seg_start_x, seg_start_y)

func mark_room_segment(sx: int, sy: int):
	for yy in range(segment_size.y):
		for xx in range(segment_size.x):
			var tile_x = sx + xx
			var tile_y = sy + yy
			if tile_x >= 0 and tile_x < map_size.x and tile_y >=0 and tile_y < map_size.y:
				if occupancy_grid[tile_y][tile_x] == true:
					# Already occupied – here you can handle a conflict (rooms overlap)
					# You can either cancel placement, find another location, or change the template
					# In this example, we just continue, but in real code you would need to resolve the conflict
					pass
				occupancy_grid[tile_y][tile_x] = true

func place_corridor(start_pos: Vector2i, direction: Vector2i, length: int):
	# Corridor width of 2 and length of specified length
	# Suppose the corridor is built such that if it goes along X, it spans 2 along Y, and if along Y, it spans 2 along X.
	# For diagonals, you can do similarly (consider both dimensions).
	var corridor_data = {
		"start": start_pos,
		"direction": direction,
		"length": length
	}
	corridors.append(corridor_data)

	# Place corridor tiles
	for i in range(length):
		for w in range(2): # width 2
			var tile_x = start_pos.x + direction.x*i + (direction.y*w) # if corridor is vertical, offset by y
			var tile_y = start_pos.y + direction.y*i + (direction.x*w) # if corridor is horizontal, offset by x
			if tile_x >= 0 and tile_x < map_size.x and tile_y >=0 and tile_y < map_size.y:
				if occupancy_grid[tile_y][tile_x] == true:
					# Again, conflict – handle as needed
					pass
				occupancy_grid[tile_y][tile_x] = true

func determine_tile_type(x: int, y: int) -> String:

	var neighbors = get_occupied_neighbors(x, y)
	var count     = neighbors.size()

	if count <= 1:
		return "corner"
	elif count == 2:
		# Possibly a side tile
		return "side"
	elif count >= 3:
		# Probably a center tile
		return "center"

	return "center"

func get_occupied_neighbors(x: int, y: int) -> Array:
	var result = []
	# Check 4 directions (up, down, left, right)
	var dirs = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for d in dirs:
		var nx = x + d.x
		var ny = y + d.y
		if nx >=0 and nx < map_size.x and ny >=0 and ny < map_size.y:
			if occupancy_grid[ny][nx] == true:
				result.append(Vector2i(nx, ny))
	return result
