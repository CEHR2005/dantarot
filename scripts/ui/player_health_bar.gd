extends ProgressBar
class_name PlayerHealthBar

@onready var Damage_bar: ProgressBar = %DamageBar

var parent_unit: BaseUnit

func _ready() -> void:
	if get_parent() != null:
		if "base_unit" in Player:
			print("base_unit here")
			parent_unit = Player.base_unit
			print(parent_unit.Health)
			max_value = parent_unit.Max_Health
			value = parent_unit.Health
			parent_unit.health_changed.connect(update)
		else:
			print("base_unit is not here")


func update() -> void:
	value = parent_unit.Health
