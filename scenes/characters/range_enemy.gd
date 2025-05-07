extends CharacterBody2D
class_name RangeEnemy

@export var bullet_scene: PackedScene
@export var bullet_speed := 300.0
@export var walk_speed  := 150.0
@export var retreat_speed := 150.0
@export var retreat_distance := 160.0	# R_min
@export var attack_distance  := 260.0	# R_max
@export var shoot_cooldown   := 1.0
@export var base_unit: BaseUnit
@onready var marker_2d_2: Marker2D = %Marker2D2
@onready var muzzle: Marker2D = %Marker2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var ap: AnimationPlayer = %AP
@onready var cd_timer: Timer = %Timer
@onready var sprite: Sprite2D = %Sprite2D

@onready var rng := RandomNumberGenerator.new()

var target: PlayerClass = Player

enum State { APPROACH, ATTACK, RETREAT }
var state = State.APPROACH

func _ready() -> void:
	cd_timer.one_shot = true
	cd_timer.wait_time = shoot_cooldown
	rng.randomize()

# ─── MAIN LOOP ────────────────────────────────────────────────────────────────
func _physics_process(_delta: float) -> void:
	if not _ensure_player():
		return

	var dist := global_position.distance_to(target.global_position)

	if dist < retreat_distance:
		state = State.RETREAT
	elif dist > attack_distance:
		state = State.APPROACH
	else:
		state = State.ATTACK

	match state:
		State.APPROACH:
			_move_towards_player()
		State.RETREAT:
			_move_away_from_player()
		State.ATTACK:
			velocity = Vector2.ZERO

	move_and_slide()
	marker_2d_2.look_at(target.global_position)

	_update_walk_animation()

	if state == State.ATTACK and cd_timer.is_stopped():
		_shoot_and_restart()

# ─── MOVEMENT ────────────────────────────────────────────────────────────────
func _move_towards_player() -> void:
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * walk_speed

func _move_away_from_player() -> void:
	var dir := (global_position - target.global_position).normalized()
	var angle := deg_to_rad(rng.randf_range(-20, 20))
	dir = dir.rotated(angle)
	velocity = dir * retreat_speed

# ─── ANIMATION ───────────────────────────────────────────────────────────────
func _update_walk_animation() -> void:

	if velocity.length() < 1.0:
		return


	if abs(velocity.y) > abs(velocity.x):
		if velocity.y > 0.0:
			animation_player.play("Walk_down")
		else:
			animation_player.play("Walk_up")
	else:
		animation_player.play("Walk_side")

		sprite.flip_h = velocity.x < 0.0

# ─── SHOOTING ────────────────────────────────────────────────────────────────
func _shoot_and_restart() -> void:
	ap.play("Attack")
	var bullet := bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = muzzle.global_position
	var dir := (target.global_position - muzzle.global_position).normalized()
	bullet.direction = dir
	bullet.speed = bullet_speed
	bullet.rotation = dir.angle()
	cd_timer.start()

func _on_timer_timeout() -> void:
	if state == State.ATTACK:
		_shoot_and_restart()

# ─── HELPERS ─────────────────────────────────────────────────────────────────
func _ensure_player() -> bool:
	if target:
		return true
	target = Player
	return target != null
