extends Resource
class_name BaseUnit
signal effects_changed
signal health_changed
signal death
@export var Health: float
@export var Max_Health: float

@export var Effects_applied: Array = []:
	set(value):
		Effects_applied = value
		effects_changed.emit()


func take_damage(damage: float):
	if damage > 0:
		if Health-damage <= 0:
			Health = 0
			death.emit()
		else:
			Health-=damage
		health_changed.emit()

func heal(heal: float):
	if heal > 0:
		if Health+heal >= Max_Health:
			Health = Max_Health
		else:
			Health-=heal
			health_changed.emit()

func apply_effects(effects: Array):
	for effect: CardEffect in effects:
		Effects_applied += effects
		if effect.damage > 0:
			take_damage(effect.damage)
		


func effect_expired():
	pass
