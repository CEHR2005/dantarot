extends ProgressBar
class_name HealthBar

@onready var Damage_bar: ProgressBar = %DamageBar

var parent_unit: BaseUnit

var potential_damage: float:
	set(value):
		Damage_bar.value = parent_unit.Health
		self.value = parent_unit.Health - value


func _ready() -> void:
	if get_parent() != null:
		var parent: Node = get_parent()
		if "base_unit" in parent:
			parent_unit = parent.base_unit
			max_value = parent_unit.Max_Health
			value = parent_unit.Health
			parent_unit.health_changed.connect(update)
		else:
			print("base_unit is not here")


func update() -> void:
	value = parent_unit.Health
