extends Node2D

const HEAD   = preload("res://snake/Head.png")
const TAIL   = preload("res://snake/Tail.png")
const SEGMENT = preload("res://snake/Segment.png")
const SPHERE = preload("res://snake/Sphere.png")

# Хардкодим «цепочку» (координаты, масштаб, текстура)
var chain_data = [
	# 1) Голова
	{
		"texture": HEAD,
		"pos": Vector2(62, -6),
		"scale": Vector2(1, 1)
	},
	# 2) Сфера (между головой и обычным сегментом)
	{
		"texture": SPHERE,
		"pos": Vector2(31, -1),
		"scale": Vector2(1, 1)
	},
	# 3) Обычный сегмент
	{
		"texture": SEGMENT,
		"pos": Vector2(17, -6),
		"scale": Vector2(1, 1)
	},
	# 4) Сфера (между обычным и первым уменьшающимся сегментом)
	{
		"texture": SPHERE,
		"pos": Vector2(0, 0),
		"scale": Vector2(1, 1)
	},
	# 5) Первый уменьшающийся сегмент (scale = 0.9)
	{
		"texture": SEGMENT,
		"pos": Vector2(-20, -6),
		"scale": Vector2(0.9, 0.9)
	},
	# 6) Сфера
	{
		"texture": SPHERE,
		"pos": Vector2(-37, 1),
		"scale": Vector2(0.9, 0.9)
	},
	# 7) Второй уменьшающийся сегмент (scale = 0.9)
	{
		"texture": SEGMENT,
		"pos": Vector2(-55, -4),
		"scale": Vector2(0.9, 0.9)
	},
	# Если нужен хвост прямо здесь:
	# {
	# 	"texture": TAIL,
	# 	"pos": Vector2(...),
	# 	"scale": Vector2(1, 1)
	# }
]

# Здесь будут храниться созданные узлы (Node2D)
var chain := []
# А тут — исходное расстояние между chain[i] и chain[i-1]
var distances := []

func _ready() -> void:
	# 1) Создаем объекты (Node2D + Sprite2D)
	for piece in chain_data:
		var node = Node2D.new()
		add_child(node)

		node.position = piece["pos"]
		node.scale = piece["scale"]

		var sprite = Sprite2D.new()
		sprite.texture = piece["texture"]
		sprite.centered = true
		node.add_child(sprite)

		chain.append(node)

	# 2) Считаем и запоминаем расстояния между соседними элементами
	# Первый элемент (голова) пусть имеет расстояние = 0 (заглушка)
	distances.append(0.0)
	for i in range(1, chain.size()):
		var dist = chain[i].position.distance_to(chain[i-1].position)
		distances.append(dist)

func _physics_process(delta: float) -> void:
	# Пример: двигаем голову к позиции курсора, а все остальные «подтягиваются»
	var mouse_pos = get_global_mouse_position()
	chain[0].position = mouse_pos

	for i in range(1, chain.size()):
		chain[i].position = constrain_distance(
			chain[i].position,
			chain[i - 1].position,
			distances[i]
		)

	# Если хочешь плавнее движение, меняй голову не сразу в mouse_pos,
	# а, например, через lerp:
	# chain[0].position = chain[0].position.lerp(mouse_pos, 0.1)

	# Можно также добавить логику "поворота" каждого звена, если нужно.

func constrain_distance(point: Vector2, anchor: Vector2, desired_dist: float) -> Vector2:
	var diff = point - anchor
	var dist = diff.length()
	if dist < 0.001:
		return point
	return anchor + diff.normalized() * desired_dist
