extends Resource
class_name BaseUnit
signal effects_changed
signal health_changed
@export var Health: float
@export var Max_Health: float

@export var Effects_applied: Array = []:
	set(value):
		Effects_applied = value
		print("Set Effects!", Effects_applied)
		effects_changed.emit()


func take_damage(damage: float):
	if damage > 0:
		if Health-damage <= 0:
			Health = 0
		else:
			Health-=damage
		health_changed.emit()
		print("damage taken:", damage)


func apply_effects(effects: Array):
	print("try to apply effects!", effects)
	for effect: CardEffect in effects:
		print("try to apllay: ", effect)
		Effects_applied += effects
		print(Effects_applied)
		if effect.damage > 0:
			take_damage(effect.damage)


func effect_expired():
	pass
