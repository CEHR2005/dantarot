extends Sprite2D
class_name Doll
@export var base_unit: BaseUnit = BaseUnit.new()
@onready var v_box_container: VBoxContainer = %VBoxContainer


func _ready() -> void:
	print('connect')
	base_unit.effects_changed.connect(update_panel)
	
	
func update_panel():

	for effect: CardEffect in base_unit.Effects_applied:
		var lable = Label.new()
		lable.text = CardEffect.Effects.keys()[effect.effect_type]
		v_box_container.add_child(lable)
