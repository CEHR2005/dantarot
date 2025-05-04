extends CharacterBody2D
class_name RangeEnemy
@onready var AP: AnimationPlayer = %AP
@onready var ATK_Range: Area2D = %AttackRange
@export var base_unit: BaseUnit = BaseUnit.new()
@export var retreat_radius := 100.0
@export var retreat_speed := 150.0
@export var bullet_scene: PackedScene
@export var bullet_speed := 300
@onready var muzzle = $Marker2D
var retreat_target: Vector2 = Vector2.ZERO
var speed: int = 150
var target: Player
enum STATE {Walk, Attack, retreat}
var State = STATE.Walk
func _process(delta: float) -> void:
	if State == STATE.Walk:
		if target != null && target.position:
			var direction: Vector2 =target.position-position
			velocity=direction.normalized()*speed
			look_at(target.position)
			move_and_slide()
		else:
			var parent = get_parent()
			if parent is Game:
				target = parent.get_player()
	if State == STATE.retreat:
		var dir = (retreat_target - global_position)
		if dir.length() < 5:
			if !ATK_Range.has_overlapping_bodies():
				State = STATE.Walk
			else:
				State = STATE.Attack
				print("attack")
		else:
			velocity = dir.normalized() * retreat_speed
			move_and_slide()

func _on_attack_range_body_entered(body: Node2D) -> void:
	AP.play("Attack")
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = muzzle.global_position
	var dir = (target.global_position - muzzle.global_position).normalized()
	bullet.direction = dir
	bullet.speed = bullet_speed
	bullet.rotation = dir.angle()
	State = STATE.Attack
	

func _on_attack_body_entered(body: Node2D) -> void:
	if body is Player:
		print("bobo")


func _on_ap_animation_finished(anim_name: StringName) -> void:
	var to_player = (target.global_position - global_position).normalized()
	var base_dir = -to_player 
	var random_angle = deg_to_rad(randf_range(-30, 30)) 
	var final_dir = base_dir.rotated(random_angle)
	retreat_target = global_position + final_dir * randf_range(retreat_radius * 0.5, retreat_radius)
	State = STATE.retreat
		
