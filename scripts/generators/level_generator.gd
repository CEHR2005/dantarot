# Рекомендуется создать отдельный класс (GDScript), например LevelGenerator.gd
# Этот класс будет генерировать данные о комнатах, их форме, положении коридоров,
# а затем отдавать информацию о том, какие тайлы должны быть где установлены.
# Далее ты сможешь пройтись по полученным данным, сопоставить с необходимыми тайлами
# (угловыми, боковыми, центральными) и заполнить TileMap.
extends Node
class_name LevelGenerator

# Конфигурация – для удобства можно хранить данные о размере сегментов, размеры уровня и т.д.
var segment_size = Vector2i(8, 8) # можно менять при инициализации
var map_size     = Vector2i(64, 64) # пример, можно задавать при старте

# Здесь можно будет указать координаты для разных типов тайлов (ты заполнишь позднее)
var tile_definitions = {
						   "corner": Vector2i(0, 0),
						   "side": Vector2i(1, 0),
						   "center": Vector2i(2, 0),
						   "transition": Vector2i(3, 0)
					   }

# Для хранения данных о уже занятых позициях – карта тайлов
var occupancy_grid = []
# Данные о сгенерированных комнатах и коридорах
var rooms     = []
var corridors = []


func _init():
	# Инициализация occupancy_grid
	occupancy_grid.resize(map_size.y)
	for i in range(map_size.y):
		occupancy_grid[i] = []
		occupancy_grid[i].resize(map_size.x)
		for j in range(map_size.x):
			occupancy_grid[i][j] = false


func generate_test():
	# Пример: Генерируем одну комнату 8x8 и из неё ведём коридор 2x4
	# Затем пытаемся сделать сложную комнату типа L-образной, 2x2 и т.п.
	# Это просто пример логики.

	# Сначала генерируем обычную комнату (односегментная)
	var room_pos   = Vector2i(10, 10)
	var room_shape = [[true]] # Односегментная – просто один блок
	place_room(room_pos, room_shape)

	# Длинная (горизонтальная) из 2 сегментов
	var long_room_pos   = Vector2i(30, 10)
	var long_room_shape = [[true, true]]
	place_room(long_room_pos, long_room_shape)

	# Г-образная (L-образная): 2x2, где один угол отсутствует
	var l_room_pos   = Vector2i(10, 30)
	var l_room_shape = [
						   [true, true],
						   [true, false]
					   ]
	place_room(l_room_pos, l_room_shape)

	# Коридор 2x4: для теста свяжем первую комнату со второй
	# Допустим коридор идёт по горизонтали
	var corridor_start = Vector2i(room_pos.x + segment_size.x/2, room_pos.y + segment_size.y) # от середины нижней стены первой комнаты
	var corridor_dir   = Vector2i(0, 1) # вниз
	place_corridor(corridor_start, corridor_dir, 4) # длина 4 тайла, ширина 2 фиксирована

	# И т.д. Можно генерировать более сложные структуры.
	# После генерации у нас есть заполненные массивы rooms и corridors,
	# а также occupancy_grid с пометками о занятых позициях.

	# Далее можно пройтись по rooms и corridors, посмотреть какие тайлы заняты
	# и поставить соответствующие тайлы (угловые, боковые, центральные, переходы).
	# Например:
	for y in range(map_size.y):
		for x in range(map_size.x):
			if occupancy_grid[y][x] == true:
				# Определяем тип тайла (угловой, боковой и т.д.)
				# Это можно сделать на основе анализа соседей (есть ли рядом другие тайлы комнаты или коридора).
				var tile_type = determine_tile_type(x, y)


# tile_type вернёт что-то вроде "corner", "side", "center" или "transition".
# Далее устанавливаем тайл в TileMap:
# tilemap.set_cell(0, Vector2i(x,y), tile_definitions[tile_type])

# На этом этапе у нас будет тестовая генерация.

func place_room(start_pos: Vector2i, shape: Array):
	# shape – это массив массивов bool, отражающий форму комнаты в сегментах
	# Например [[true,true],[true,false]]
	# Каждый true – сегмент 8x8.

	var room_data = {
						"position": start_pos,
						"shape": shape
					}
	rooms.append(room_data)

	# Раскладываем сегменты по карте
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
					# Уже занято – здесь можно обработать конфликт (комнаты накладываются)
					# Можно либо отменить установку, либо искать другое место, либо менять шаблон
					# Для примера просто продолжаем, но в реальном коде нужно будет решить конфликт
					pass
				occupancy_grid[tile_y][tile_x] = true


func place_corridor(start_pos: Vector2i, direction: Vector2i, length: int):
	# Коридор 2 в ширину и length в длину
	# Допустим, коридор выстроен так, что если идёт по X, то он 2 по Y, если по Y – то 2 по X.
	# Для диагоналей можно сделать аналогично (учесть оба измерения).
	var corridor_data = {
							"start": start_pos,
							"direction": direction,
							"length": length
						}
	corridors.append(corridor_data)

	# Расставляем тайлы коридора
	for i in range(length):
		for w in range(2): # ширина 2
			var tile_x = start_pos.x + direction.x*i + (direction.y*w) # если коридор вертикальный, сдвиг по y
			var tile_y = start_pos.y + direction.y*i + (direction.x*w) # если коридор горизонтальный, сдвиг по x
			if tile_x >= 0 and tile_x < map_size.x and tile_y >=0 and tile_y < map_size.y:
				if occupancy_grid[tile_y][tile_x] == true:
					# Опять же конфликт – обрабатываем по необходимости
					pass
				occupancy_grid[tile_y][tile_x] = true


func determine_tile_type(x: int, y: int) -> String:
	# Проверяем соседей, чтобы определить тип тайла.
	# Можно посмотреть на наличие соседей по 4 направлениям (или 8, если надо)
	# и понять, угловой ли это тайл (мало соседей), боковой (1 сосед), центральный (>2 соседей)
	# или переходный (где соединяется коридор и комната).
	# Это просто пример логики.

	var neighbors = get_occupied_neighbors(x, y)
	var count     = neighbors.size()

	if count <= 1:
		return "corner"
	elif count == 2:
		# Возможно боковой
		return "side"
	elif count >= 3:
		# Вероятно центральный
		return "center"

	# Для перехода можно ввести отдельную логику, где проверяем,
	# совпадают ли соседи с типом комнаты/коридора.
	# Например, если tile окружён с одной стороны комнатой, с другой – коридором,
	# тогда это "transition".
	# В данном примере просто возвращаем "center" по умолчанию.

	return "center"


func get_occupied_neighbors(x: int, y: int) -> Array:
	var result = []
	# Проверим 4 направления (вверх, вниз, лево, право)
	var dirs = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for d in dirs:
		var nx = x + d.x
		var ny = y + d.y
		if nx >=0 and nx < map_size.x and ny >=0 and ny < map_size.y:
			if occupancy_grid[ny][nx] == true:
				result.append(Vector2i(nx, ny))
	return result
