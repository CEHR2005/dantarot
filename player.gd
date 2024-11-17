extends CharacterBody2D

@export var deck: Deck
@export var hand: Hand
@onready var AP: AnimationPlayer = %AP
@onready var sprite_2d: Sprite2D = %Sprite2D

var speed := 400
var screen_size
func _ready() -> void:
	AP.play("Base")
	screen_size = get_viewport_rect().size

func _process(delta):
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
