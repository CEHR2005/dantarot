extends Resource
class_name BaseUnit
signal effects_changed

@export var Hp: int
@export var Effects_applied: Array = []:
	set(value):
		Effects_applied = value
		print("Set Effects!", Effects_applied)
		effects_changed.emit()

func take_damage(damage: float):
	Hp-=damage

func apply_effects(effects: Array):
	print("try to apply effects!", effects)
	for effect: CardEffect in effects:
		print("try to apllay: ", effect)
		Effects_applied += effects
		print(Effects_applied)
func effect_expired():
	pass
