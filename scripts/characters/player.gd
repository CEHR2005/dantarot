extends CharacterBody2D
class_name PlayerClass

################################################################################
# Constants                                                                     #
################################################################################

const GAME					:= preload("res://scenes/levels/game.tscn")

# Movement
const WALK_SPEED			:= 100.0
const DASH_SPEED			:= 450.0
const DASH_DURATION		:= 0.2		# seconds the dash lasts
const DOUBLE_TAP_WINDOW	:= 0.3		# seconds between taps for dash
const DASH_CARD_NAME	:= "Dash"

# Health
const MAX_HEALTH			:= 100.0

################################################################################
# Exported / On‑ready                                                           #
################################################################################
signal HandChanged
@export var deck: Deck
@export var hand: Hand
@export var base_unit: BaseUnit

@onready var AP: AnimationPlayer		= %AP
@onready var sprite: Sprite2D			= %Sprite2D

################################################################################
# Private state                                                                 #
################################################################################

var _screen_size: Vector2
var _health: float			= MAX_HEALTH
var potential = 0
# Dash
var _is_dashing: bool			= false
var _dash_timer: float		= 0.0
var _dash_dir: Vector2		= Vector2.ZERO
var _last_tap_times := {
	"ui_left":	0.0,
	"ui_right":	0.0,
	"ui_up":		0.0,
	"ui_down":	0.0,
}

# Card preview
var _preview_area: Area2D
var _preview_shape: CollisionShape2D
var _hovered_doll: Doll = null
################################################################################
# Card input map                                                                #
################################################################################
const CARD_ACTIONS := [
	"Card1",
	"Card2",
	"Card3",
	"Card4",
	"Card5"	
]

var _active_card_idx: int = -1	

################################################################################
# Engine callbacks                                                              #
################################################################################

func _ready() -> void:
	AP.play("Base")
	_screen_size = get_viewport_rect().size
	_init_preview_area()

func _unhandled_input(event: InputEvent) -> void:
	# проверяем каждую CardN
	for i in CARD_ACTIONS.size():
		var act = CARD_ACTIONS[i]
		if Input.is_action_just_pressed(act):
			_active_card_idx = i
			_start_aim()
			break		
		elif Input.is_action_just_released(act) and _active_card_idx == i:
			_commit_aim()
			_active_card_idx = -1
			break

func _process(delta: float) -> void:
	if _preview_area.monitoring:
		_update_preview_position()
		_update_hover_highlight()

func _physics_process(delta: float) -> void:
	_handle_dash_state(delta)
	_handle_movement(delta)

################################################################################
# Health                                                                        #
################################################################################

func take_damage(amount: float) -> void:
	_health = clamp(_health - amount, 0.0, MAX_HEALTH)
	print("HP:", _health)

################################################################################
# Movement & Dash                                                               #
################################################################################

func _handle_movement(delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	)

	if _is_dashing:
		velocity = _dash_dir * DASH_SPEED
	else:
		_handle_double_tap()
		velocity = input_vector.normalized() * WALK_SPEED

	position += velocity * delta
	move_and_slide()

	if velocity.length_squared() > 0.0:
		_update_move_animation()
	else:
		_update_idle_animation()

func _handle_double_tap() -> void:
	var now := Time.get_ticks_msec() / 1000.0
	for action in _last_tap_times.keys():
		if Input.is_action_just_pressed(action):
			if now - _last_tap_times[action] <= DOUBLE_TAP_WINDOW:
				var dir := _collect_direction(action)
				if dir.length_squared() > 0.0:
					# dash only if we can consume a Dash card
					if _consume_dash_card():
						_start_dash(dir.normalized())
					else:
						print("No Dash card in hand!")
			_last_tap_times[action] = now

func _collect_direction(first: String) -> Vector2:
	var dir := _action_to_vector(first)
	for held in _last_tap_times.keys():
		if held != first and Input.is_action_pressed(held):
			dir += _action_to_vector(held)
	return dir

func _consume_dash_card() -> bool:
	if hand.remove_first_named(DASH_CARD_NAME):
		# keep active‑index in sync
		if _active_card_idx >= hand.cards.size():
			_clear_preview()
			_active_card_idx = -1
		return true
	return false


func _start_dash(direction: Vector2) -> void:
	_is_dashing = true
	_dash_dir = direction
	_dash_timer = DASH_DURATION

func _handle_dash_state(delta: float) -> void:
	if _is_dashing:
		_dash_timer -= delta
		if _dash_timer <= 0.0:
			_is_dashing = false

func _action_to_vector(action: String) -> Vector2:
	match action:
		"ui_left":	return Vector2.LEFT
		"ui_right":	return Vector2.RIGHT
		"ui_up":	return Vector2.UP
		"ui_down":	return Vector2.DOWN
		_:				return Vector2.ZERO

################################################################################
# Card preview & targeting                                                      #
################################################################################

func _init_preview_area() -> void:
	_preview_area = Area2D.new()
	_preview_area.monitoring = false
	_preview_area.set_collision_layer_value(3, true)
	_preview_area.set_collision_mask_value(1, false)
	_preview_area.set_collision_mask_value(2, true)
	
	add_child(_preview_area)

	_preview_shape = CollisionShape2D.new()
	_preview_area.add_child(_preview_shape)

func _get_active_card() -> Card:
	if _active_card_idx < 0 or _active_card_idx >= hand.cards.size():
		return null
	return hand.cards[_active_card_idx]

func _start_aim() -> void:
	var card := _get_active_card()
	if card == null:
		return

	card.activate()

	if card.TargetType != Card.TargetTypeList.Area:
		return

	_preview_shape.shape = card.cardArea
	_update_preview_position()
	_preview_area.monitoring = true
func _commit_aim() -> void:
	if not _preview_area.monitoring:
		return

	var card := _get_active_card()
	if card:
		_apply_card_to_overlaps(card)

	_clear_preview()

func _apply_card_to_overlaps(card: Card) -> void:
	for body in _preview_area.get_overlapping_bodies():
		if "base_unit" in body:
			body.base_unit.apply_effects(card.card_effects)

func _update_preview_position() -> void:
	_preview_area.global_position = get_global_mouse_position()


func _update_hover_highlight() -> void:
	var card := _get_active_card()
	var potential := 0
	if card and card.card_effects.size() > 0:
		potential = card.card_effects[0].damage

	var current: Doll = null
	for body in _preview_area.get_overlapping_bodies():
		var parent := body.get_parent()
		if parent is Doll:
			current = parent
			break

	if current and current != _hovered_doll:
		print("Hover enter:", current.name)
	elif not current and _hovered_doll:
		print("Hover exit:", _hovered_doll.name)
		_hovered_doll.Health_bar.potential_damage = 0

	if current:
		current.Health_bar.potential_damage = potential

	_hovered_doll = current

func _clear_preview() -> void:
	_preview_area.monitoring = false
	_hovered_doll = null

################################################################################
# Animation helpers                                                             #
################################################################################

func _update_idle_animation() -> void:
	var dir := (get_global_mouse_position() - global_position).normalized()
	var _name := "idle_" + _vector_to_dir_string(dir)
	AP.play(_name)

func _update_move_animation() -> void:
	var dir := velocity.normalized()
	var _name := _vector_to_dir_string(dir).capitalize()
	AP.play(_name)

func _vector_to_dir_string(v: Vector2) -> String:
	if abs(v.x) > abs(v.y):
		if v.x >= 0:
			return "right"
		else:
			sprite.flip_h = true
			return "left"
	else:
		if v.y >= 0:
			return "down"
		else:
			return "up"
