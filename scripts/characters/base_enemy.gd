extends CharacterBody2D
@onready var AP: AnimationPlayer = %AP
@onready var ATK_Range: Area2D = %AttackRange
@export var base_unit: BaseUnit = BaseUnit.new()
@onready var marker_2d: Marker2D = %Marker2D2
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite: Sprite2D = %Sprite2D

var speed: int = 150
var target
enum STATE {Walk, Attack}
var State = STATE.Walk
func _ready() -> void:
	base_unit.death.connect(unspawn)
	
func unspawn():
	self.queue_free()

func _process(delta: float) -> void:
	if State == STATE.Walk:
		if target != null && target.position:
			var direction: Vector2 =target.position-position
			velocity=direction.normalized()*speed
			marker_2d.look_at(target.position)
			move_and_slide()
			_update_walk_animation()
		else:
			target = Player


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

func _on_attack_range_body_entered(body: Node2D) -> void:
	AP.play("Attack")
	State = STATE.Attack
	

func _on_attack_body_entered(body: Node2D) -> void:
	if body is PlayerClass:
		body.base_unit.take_damage(10)


func _on_ap_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack":
		if ATK_Range.has_overlapping_bodies():
			AP.play("Attack")
		else:
			State = STATE.Walk
		
