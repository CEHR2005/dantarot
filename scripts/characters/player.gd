extends CharacterBody2D
class_name Player

@export var deck: Deck
@export var hand: Hand

@onready var AP: AnimationPlayer = %AP
@onready var sprite_2d: Sprite2D =  %Sprite2D
const GAME                       =  preload("res://scenes/levels/game.tscn")
var speed                        := 400
var screen_size
var area: Area2D
var collision: CollisionShape2D


func _ready() -> void:
	AP.play("Base")
	screen_size = get_viewport_rect().size


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("Card1"):
			print("press")
			#var card = Card.new()
			var card: Card = hand.cards[0]
			card.activate()
			if card.TargetType == Card.TargetTypeList.Area:
				area = Area2D.new()
				area.position = get_global_mouse_position()
				get_parent().add_child(area)
				collision = CollisionShape2D.new()
				collision.shape = card.cardArea
				area.add_child(collision)
		if event.is_action_released("Card1"):
			var card: Card        = hand.cards[0]
			var overlapping_areas = area.get_overlapping_areas()
			for area in overlapping_areas:
				print("Area", area)
				print("Parent", area.get_parent())
			var overlapping_bodies = area.get_overlapping_bodies()
			for body in overlapping_bodies:
				print("body: ", body)
				print(body.get_class())
				var parent = body.get_parent()
				print("Parent: ", parent)
				print(parent.get_class())
				if parent is Doll:
					var doll: Doll = parent
					doll.base_unit.apply_effects(card.card_effects)
			area.queue_free()

var last_hovered_doll: Doll = null


func _process(delta):
	if is_instance_valid(area):
		area.position = get_global_mouse_position()
		var overlapping_bodies = area.get_overlapping_bodies()

		var current_hovered_doll: Doll = null

		for body in overlapping_bodies:
			var parent = body.get_parent()
			if parent is Doll:
				current_hovered_doll = parent
				break

		if current_hovered_doll != null:
			if current_hovered_doll != last_hovered_doll:
				print("Курсор навёлся на новую куклу")
			var card: Card = hand.cards[0]
			current_hovered_doll.Health_bar.potential_damage = card.card_effects[0].damage
		elif last_hovered_doll != null:
			print("Курсор ушёл с куклы: ", last_hovered_doll.name)
			last_hovered_doll.Health_bar.potential_damage = 0

		last_hovered_doll = current_hovered_doll

	var velocity = Vector2.ZERO
	# Проверка нажатия клавиш и определение направления
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
		sprite_2d.flip_h = false
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
		sprite_2d.flip_h = true
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1

	# Нормализуем вектор для корректного передвижения по диагонали
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	# Перемещаем персонажа
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	move_and_slide()
