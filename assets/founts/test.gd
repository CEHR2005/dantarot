extends Node2D

# Предположим, у нас есть соответствующие текстуры:
const HEAD              = preload("res://snake/Head_c.png")
const TAIL              = preload("res://snake/Tail_b.png")
const SEGMENT           = preload("res://snake/Segment_b.png")
const SEGMENT_SHRINKING = preload("res://snake/Segment_Shrinking_b.png")
const SPHERE            = preload("res://snake/Sphere.png")
const max_angle_deg = 15

var chain_data = [
					 {
						 "name": "Head",
						 "texture": HEAD,
						 "pos": Vector2(62, -100),
						 "scale": Vector2(1, 1),
						 "length": 0.0
					 },
					 {
						 "name": "Sphere3",
						 "texture": SPHERE,
						 "pos": Vector2(31, -1),
						 "scale": Vector2(1, 1),
						 "length": 0
					 },
					 {
						 "name": "Segment",
						 "texture": SEGMENT,
						 "pos": Vector2(17, -6),
						 "scale": Vector2(1, 1),
						 "length": 14.9
					 },
					 {
						 "name": "Sphere",
						 "texture": SPHERE,
						 "pos": Vector2(0, 0),
						 "scale": Vector2(1, 1),
						 "length": 18.0
					 },
					 {
						 "name": "SegmentShrinking",
						 "texture": SEGMENT_SHRINKING,
						 "pos": Vector2(-20, -6),
						 "scale": Vector2(1, 1),
						 "length": 20.9
					 },
					 {
						 "name": "Sphere2",
						 "texture": SPHERE,
						 "pos": Vector2(-37, 1),
						 "scale": Vector2(0.9, 0.9),
						 "length": 18.4
					 },
					 {
						 "name": "SegmentShrinking2",
						 "texture": SEGMENT_SHRINKING,
						 "pos": Vector2(-55, -4),
						 "scale": Vector2(0.9, 0.9),
						 "length": 18.7
					 },
					 {
						 "name": "Sphere4",
						 "texture": SPHERE,
						 "pos": Vector2(-69, 2),
						 "scale": Vector2(0.81, 0.81),
						 "length": 15.2
					 },
					 {
						 "name": "SegmentShrinking3",
						 "texture": SEGMENT_SHRINKING,
						 "pos": Vector2(-86, -2),
						 "scale": Vector2(0.81, 0.81),
						 "length": 17.5
					 },
					 {
						 "name": "Sphere5",
						 "texture": SPHERE,
						 "pos": Vector2(-100, 4),
						 "scale": Vector2(0.729, 0.729),
						 "length": 15.2
					 },
					 {
						 "name": "SegmentShrinking4",
						 "texture": SEGMENT_SHRINKING,
						 "pos": Vector2(-114, 0),
						 "scale": Vector2(0.729, 0.729),
						 "length": 14.6
					 },
					 {
						 "name": "Sphere6",
						 "texture": SPHERE,
						 "pos": Vector2(-126, 5),
						 "scale": Vector2(0.656, 0.656),
						 "length": 13.0
					 },
					 {
						 "name": "Tail",
						 "texture": TAIL,
						 "pos": Vector2(-151, 2),
						 "scale": Vector2(1, 1),
						 "length": 25.2
					 },
				 # Допустим, добавили ещё одну "Sphere7" (если нужно)
					 {
						 "name": "Sphere7",
						 "texture": SPHERE,
						 "pos": Vector2(-181, 5),
						 "scale": Vector2(0.656, 0.656),
						 "length": 25.0
					 },
				 ]

var chain_nodes: Array[Node2D] = []
var lengths: Array[float]      = []


func _ready() -> void:
	var i: int = 0
	for piece in chain_data:
		var node = Node2D.new()
		node.name = piece["name"]
		add_child(node)

		node.position = piece["pos"]
		node.scale = piece["scale"]

		var sprite = Sprite2D.new()
		sprite.texture = piece["texture"]
		sprite.z_index = i
		i -= 1
		if sprite.texture == SPHERE:
			sprite.z_index = i-1
		sprite.centered = true
		if node.name == "Sphere7":
			sprite.visible = false
		node.add_child(sprite)

		chain_nodes.append(node)
		lengths.append(piece["length"])


func _physics_process(delta: float) -> void:
	if chain_nodes.size() < 2:
		return

	# --- 1) Делаем плавное движение головы (индекс 0)
	#     Интерполируем позицию головы к мыши.
	var alpha        := 0.05  # Чем меньше, тем плавнее движется
	var old_head_pos =  chain_nodes[0].position
	chain_nodes[0].position = chain_nodes[0].position.lerp(get_global_mouse_position(), alpha)

	# Поворачиваем голову по направлению движения
	var head_dir = chain_nodes[0].position - old_head_pos
	if head_dir.length() > 0.01:
		chain_nodes[0].rotation = head_dir.angle()

	# --- 2) Притягиваем остальные звенья на их фиксированные length
	for i in range(1, chain_nodes.size()):
		var old_pos    = chain_nodes[i].position
		var anchor_pos = chain_nodes[i - 1].position
		var dist       = lengths[i]

		chain_nodes[i].position = constrain_distance(old_pos, anchor_pos, dist)

	# --- 3) Выравниваем сегменты по сферам
	# align_segment_between_spheres(сегмент, левая_сфера, правая_сфера)
	align_segment_between_spheres(2, 3, 1)    # Segment (idx 2) между Sphere (idx 3) и Sphere3 (idx 1)
	align_segment_between_spheres(4, 5, 3)
	align_segment_between_spheres(6, 7, 5)
	align_segment_between_spheres(8, 9, 7)
	align_segment_between_spheres(10, 11, 9)
	align_segment_between_spheres(12, 13, 11)


# Если есть Sphere7, нужно смотреть, где именно она в иерархии.

func align_segment_between_spheres(idx_segment: int, idx_sphere_left: int, idx_sphere_right: int) -> void:
	var segment_node = chain_nodes[idx_segment]
	var sphere_left  = chain_nodes[idx_sphere_left]
	var sphere_right = chain_nodes[idx_sphere_right]

	var pL        = sphere_left.position
	var pR        = sphere_right.position
	var direction = pR - pL
	var new_angle = direction.angle()

	# Ограничиваем резкий поворот сегмента
	var old_angle   = segment_node.rotation
	var angle_diff  = wrapf(new_angle - old_angle, -PI, PI)
	var max_angle   = deg_to_rad(max_angle_deg)
	angle_diff = clamp(angle_diff, -max_angle, max_angle)
	var final_angle = old_angle + angle_diff

	segment_node.rotation = final_angle

	# Ставим в центр между двумя сферами (если хотим «распорку»)
	var midpoint = (pL + pR) * 0.5
	segment_node.position = midpoint


# Если нужно растягивать (см. комментарий в коде):
# var dist = direction.length()
# var sprite_seg = segment_node.get_child(0) as Sprite2D
# if sprite_seg and sprite_seg.texture:
#     var tex_w = sprite_seg.texture.get_width()
#     if tex_w > 0:
#         var desired_scale_x = dist / float(tex_w)
#         segment_node.scale = Vector2(desired_scale_x, segment_node.scale.y)

func constrain_distance(point: Vector2, anchor: Vector2, distance: float) -> Vector2:
	var diff    = point - anchor
	var cur_len = diff.length()
	if cur_len < 0.0001:
		return anchor
	return anchor + diff.normalized() * distance
