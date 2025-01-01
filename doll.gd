extends Sprite2D
class_name Doll
@export var base_unit: BaseUnit = BaseUnit.new()
@export var lable_settings: LabelSettings
@onready var v_box_container: VBoxContainer = %VBoxContainer


func _ready() -> void:
	print('connect')
	base_unit.effects_changed.connect(update_panel)
	
	
func update_panel():
	for child in v_box_container.get_children():
		v_box_container.remove_child(child)
		child.queue_free()
	for effect: CardEffect in base_unit.Effects_applied:
		var lable = Label.new()
		lable.text = CardEffect.Effects.keys()[effect.effect_type]
		lable.label_settings = lable_settings
		v_box_container
		v_box_container.add_child(lable)
