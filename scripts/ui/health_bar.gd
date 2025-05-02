extends ProgressBar
class_name HealthBar

@onready var Damage_bar: ProgressBar = %DamageBar

var parent_unit: BaseUnit

var potential_damage: float:
	set(value):
		print(value)
		Damage_bar.value = parent_unit.Health
		self.value = parent_unit.Health - value


func _ready() -> void:
	if get_parent() != null:
		var parent: Node = get_parent()
		if "base_unit" in parent:
			print("base_unit here")
			parent_unit = parent.base_unit
			print(parent_unit.Health)
			max_value = parent_unit.Max_Health
			value = parent_unit.Health
			parent_unit.health_changed.connect(update)
		else:
			print("base_unit is not here")


func update() -> void:
	print(">>> update() called")
	print("Health:", parent_unit.Health)
	print("max_value:", max_value)
	print("value до:", value)

	value = parent_unit.Health

	print("value после:", value)
