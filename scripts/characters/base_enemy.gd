extends CharacterBody2D
@onready var AP: AnimationPlayer = %AP
@onready var ATK_Range: Area2D = %AttackRange
@export var base_unit: BaseUnit = BaseUnit.new()
var speed: int = 150
var target
enum STATE {Walk, Attack}
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


func _on_attack_range_body_entered(body: Node2D) -> void:
	AP.play("Attack")
	State = STATE.Attack
	

func _on_attack_body_entered(body: Node2D) -> void:
	if body is Player:
		print("bobo")


func _on_ap_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack":
		if ATK_Range.has_overlapping_bodies():
			print(1)
			print(ATK_Range.get_overlapping_bodies())
			AP.play("Attack")
		else:
			State = STATE.Walk
		
