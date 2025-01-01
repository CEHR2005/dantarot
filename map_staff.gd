extends Node2D

@onready var tile_map_layer: TileMapLayer = %TileMapLayer

const MAP_SIZE = 32
const RADIUS = MAP_SIZE / 2
const CENTER = Vector2i(RADIUS,RADIUS)

const ROOM_SIZE = Vector2i(3,3)
const ROOM_COUNT = 10

var occupancy_grid = []
var rooms = [] # будет хранить словари с {"pos": Vector2i, "center": Vector2i}
var rng = RandomNumberGenerator.new()
var coridors: Array = []
# Определим source_id и coords для разных тайлов:
# Теперь тайлы комнаты – это 3x3 уникальных тайлов с координатами от (0,0) до (2,2)
var TILE_EMPTY = {"source_id": -1, "atlas_coords": Vector2i(-1,-1), "alt": -1} # нет тайла
var TILE_WALL = {"source_id":0, "atlas_coords":Vector2i(1,1), "alt":0} # пусть 0,0 используется для стены круг
# Комнаты: 3x3 тайла, каждый уникальный
# Считаем, что все они идут из одного source_id=0, но с разными atlas_coords
# Для наглядности возьмём:
# (0,0) - верхний левый угол
# (1,0) - верх
# (2,0) - верхний правый угол
# (0,1) - слева
# (1,1) - центр
# (2,1) - справа
# (0,2) - нижний левый
# (1,2) - низ
# (2,2) - нижний правый угол
# В данном случае это те же координаты, что и для стены, но можно представить, что у нас есть другой source или просто другой набор тайлов.
# Для примера используем один и тот же source_id, но подразумеваем разные тайлы внутри него.
#
# В реальности нужно настроить TileSet так, чтобы эти все координаты (0,0) ... (2,2) были разными тайлами комнаты.
#
# Будем вычислять atlas_coords по (xx, yy) прямо в place_room.


# TOP, RIGHT, BOTTOM, LEFT
var Cells: Dictionary = {
	[true, false, true, false]: Vector2i(3, 1),
	[false, true, false, true]: Vector2i(1, 3),
	
	[false, true, true, false]: Vector2i(4, 0),
	[false, false, true, true]: Vector2i(7, 0),
	[true, true, false, false]: Vector2i(4, 3),
	[true, false, false, true]: Vector2i(7, 3),
}

var TILE_CORRIDOR = {"source_id":0, "atlas_coords":Vector2i(3,0), "alt":0} # например (3,0) - коридор

func _ready():
	tile_map_layer.clear()
	rng.randomize()

	_init_occupancy_grid()
	_draw_circle_boundary()
	place_rooms()
	connect_rooms()
	tile_map_layer.update_internals()


func _init_occupancy_grid():
	occupancy_grid.resize(MAP_SIZE)
	for y in range(MAP_SIZE):
		occupancy_grid[y] = []
		for x in range(MAP_SIZE):
			occupancy_grid[y].append(false)


func _draw_circle_boundary():
	for y in range(MAP_SIZE):
		for x in range(MAP_SIZE):
			var dist = Vector2i(x,y).distance_to(CENTER)
			if dist > RADIUS:
				tile_map_layer.set_cell(Vector2i(x,y), TILE_WALL.source_id, TILE_WALL.atlas_coords, TILE_WALL.alt)
				occupancy_grid[y][x] = true
			else:
				tile_map_layer.set_cell(Vector2i(x,y), TILE_EMPTY.source_id, TILE_EMPTY.atlas_coords, TILE_EMPTY.alt)


func place_rooms():
	var placed = 0
	var attempts = 0
	while placed < ROOM_COUNT and attempts < 1000:
		attempts += 1
		var room_pos = get_random_room_position()
		if can_place_room(room_pos):
			place_room(room_pos)
			placed += 1

func get_random_room_position() -> Vector2i:
	var x = rng.randi_range(0, MAP_SIZE - ROOM_SIZE.x)
	var y = rng.randi_range(0, MAP_SIZE - ROOM_SIZE.y)
	return Vector2i(x,y)

func can_place_room(start_pos: Vector2i) -> bool:
	for yy in range(ROOM_SIZE.y):
		for xx in range(ROOM_SIZE.x):
			var tx = start_pos.x + xx
			var ty = start_pos.y + yy
			if tx < 0 or tx >= MAP_SIZE or ty < 0 or ty >= MAP_SIZE:
				return false
			if occupancy_grid[ty][tx]:
				return false
			var dist = Vector2i(tx, ty).distance_to(CENTER)
			if dist > RADIUS:
				return false
	return true

func place_room(start_pos: Vector2i):
	var room_center = start_pos + ROOM_SIZE/2
	rooms.append({"pos": start_pos, "center": room_center})

	for yy in range(ROOM_SIZE.y):
		for xx in range(ROOM_SIZE.x):
			var tx = start_pos.x + xx
			var ty = start_pos.y + yy
			occupancy_grid[ty][tx] = true
			var atlas_coords = Vector2i(xx, yy) # согласно позиции в 3x3
			tile_map_layer.set_cell(Vector2i(tx,ty), 0, atlas_coords, 0)


func connect_rooms():
	if rooms.size() < 2:
		return
	rooms.sort_custom(_sort_rooms_by_center_x)

	for i in range(rooms.size() - 1):
		var room_a = rooms[i]
		var room_b = rooms[i+1]
		create_corridor_between_rooms(room_a, room_b)
	redraw_coridors()


func _sort_rooms_by_center_x(a, b):
	return a["center"].x < b["center"].x

func test(te: Vector2i):
	if tile_map_layer.get_cell_atlas_coords(te) == Vector2i(-1, -1):
		return false
	else:
		return true

func create_corridor_between_rooms(room_a, room_b):
	var start_tiles = get_room_tiles(room_a)
	var goal_tiles = get_room_tiles(room_b)

	var path = find_path_any_to_any(start_tiles, goal_tiles)
	if path.size() > 0:
		for p in path:
			if tile_map_layer.get_cell_source_id(p) == -1:
				tile_map_layer.set_cell(p, TILE_CORRIDOR.source_id, TILE_CORRIDOR.atlas_coords, TILE_CORRIDOR.alt)
				coridors.append(p)
	else:
		print("Path not found between", room_a["center"], "and", room_b["center"])

func redraw_coridors():
	for c in coridors:
		var neighbors: Array = [
		tile_map_layer.get_neighbor_cell(c, TileSet.CELL_NEIGHBOR_TOP_SIDE),
		tile_map_layer.get_neighbor_cell(c, TileSet.CELL_NEIGHBOR_RIGHT_SIDE),
		tile_map_layer.get_neighbor_cell(c, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE),
		tile_map_layer.get_neighbor_cell(c, TileSet.CELL_NEIGHBOR_LEFT_SIDE)
	]
		print(c)
		print(neighbors)
		print(neighbors.map(test))
		var atlas_cord = Cells.get(neighbors.map(test))
		if atlas_cord == null: 
			atlas_cord = Vector2i(3,3)
		tile_map_layer.set_cell(c, TILE_CORRIDOR.source_id, atlas_cord, TILE_CORRIDOR.alt)	

func get_room_tiles(room):
	var tiles = []
	var start = room["pos"]
	for yy in range(ROOM_SIZE.y):
		for xx in range(ROOM_SIZE.x):
			var tile_pos = Vector2i(start.x + xx, start.y + yy)
			tiles.append(tile_pos)
	return tiles

func find_path_any_to_any(start_positions: Array, goal_positions: Array) -> Array:
	var goals = {}
	for g in goal_positions:
		goals[str(g)] = true

	var visited = {}
	var queue = []
	for sp in start_positions:
		queue.append({"pos": sp, "path":[sp]})
		visited[str(sp)] = true

	var dirs = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]

	while queue.size() > 0:
		var current = queue.pop_front()
		var cpos = current.pos
		var cpath = current.path

		if goals.has(str(cpos)):
			return cpath

		for d in dirs:
			var np = Vector2i(cpos.x + d.x, cpos.y + d.y)
			if np.x < 0 or np.x >= MAP_SIZE or np.y < 0 or np.y >= MAP_SIZE:
				continue
			if visited.has(str(np)):
				continue

			if is_walkable_simple(np):
				var new_path = cpath.duplicate()
				new_path.append(np)
				queue.append({"pos":np, "path":new_path})
				visited[str(np)] = true
	return []

func is_walkable_simple(pos: Vector2i) -> bool:
	var dist = pos.distance_to(CENTER)
	if dist > RADIUS:
		return false
	return true
