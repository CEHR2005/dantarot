extends Node2D

const HEAD    = preload("res://assets/images/snake/Head_c.png")
const TAIL    = preload("res://assets/images/snake/Tail_b.png") 
const SEGMENT = preload("res://assets/images/snake/Segment_b.png")
const SPHERE  = preload("res://assets/images/snake/Sphere.png")


const NUM_SPHERES        := 10          
const INITIAL_DISTANCE   := 35.0      
const INITIAL_HEAD_POS   := Vector2.ZERO  
const INITIAL_DIRECTION  := Vector2.LEFT   


const BASE_SPHERE_SCALE  := 1.0  
const BASE_TAIL_SCALE    := 1.0  
const SCALE_FACTOR       := 0.9  


const TAIL_OFFSET        := 13.0 


var spheres  : Array[Node2D] = []  
var tails    : Array[Node2D] = []  
var distances               = []   

var head_node : Node2D
var tail_node : Node2D

func _ready() -> void:
	_create_spheres_scaled()
	_cache_distances()
	_create_tail_segments()
	_create_head()
	_create_tail_end()


func _create_spheres_scaled() -> void:
	var sphere_scale := BASE_SPHERE_SCALE
	var distance := INITIAL_DISTANCE
	var pos := INITIAL_HEAD_POS
	for i in range(NUM_SPHERES):
		var node := Node2D.new()
		add_child(node)

		node.position = pos
		node.scale    = Vector2(sphere_scale, sphere_scale)

		var sprite := Sprite2D.new()
		sprite.texture = SPHERE
		sprite.centered = true
		node.add_child(sprite)

		spheres.append(node)


		sphere_scale *= SCALE_FACTOR
		pos += INITIAL_DIRECTION * distance
		distance *= SCALE_FACTOR


func _cache_distances() -> void:
	distances.append(0.0)
	for i in range(1, spheres.size()):
		distances.append(spheres[i].position.distance_to(spheres[i - 1].position))


func _create_tail_segments() -> void:
	var tail_scale := BASE_TAIL_SCALE
	for i in range(spheres.size() - 1):
		var seg := Node2D.new()
		add_child(seg)

		var sprite := Sprite2D.new()
		sprite.texture = SEGMENT
		sprite.centered = true
		seg.add_child(sprite)

		seg.scale = Vector2(tail_scale, tail_scale)
		_update_tail_mid_transform(seg, spheres[i], spheres[i + 1])

		tails.append(seg)
		tail_scale *= SCALE_FACTOR


func _create_head() -> void:
	head_node = Node2D.new()
	add_child(head_node)
	head_node.position = spheres[0].position
	var spr := Sprite2D.new()
	spr.texture = HEAD
	spr.centered = true
	spr.position = Vector2(-5, 0) 
	head_node.add_child(spr)


func _create_tail_end() -> void:
	tail_node = Node2D.new()
	add_child(tail_node)
	var spr := Sprite2D.new()
	spr.texture = TAIL
	spr.centered = true
	tail_node.add_child(spr)
	tail_node.scale = Vector2(BASE_TAIL_SCALE * pow(SCALE_FACTOR, NUM_SPHERES - 1), BASE_TAIL_SCALE * pow(SCALE_FACTOR, NUM_SPHERES - 1))


func _physics_process(delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	spheres[0].position = mouse_pos

	for i in range(1, spheres.size()):
		spheres[i].position = constrain_distance(
			spheres[i].position,
			spheres[i - 1].position,
			distances[i]
		)

	for i in range(tails.size()):
		_update_tail_mid_transform(tails[i], spheres[i], spheres[i + 1])

	_update_head_transform()
	_update_tail_end_transform()


func _update_tail_mid_transform(tail: Node2D, left: Node2D, right: Node2D) -> void:
	tail.position = left.position.lerp(right.position, 0.5)
	tail.rotation = (left.position - right.position).angle()

func _update_head_transform() -> void:
	head_node.position = spheres[0].position
	var dir := spheres[0].position - spheres[1].position
	head_node.rotation = dir.angle()

func _update_tail_end_transform() -> void:
	var dir = spheres.back().position - spheres[spheres.size() - 2].position
	tail_node.position = spheres.back().position + dir.normalized() * TAIL_OFFSET
	tail_node.rotation = dir.angle() + PI

func constrain_distance(point: Vector2, anchor: Vector2, desired_dist: float) -> Vector2:
	var diff := point - anchor
	var dist := diff.length()
	if dist < 0.001:
		return point
	return anchor + diff.normalized() * desired_dist
