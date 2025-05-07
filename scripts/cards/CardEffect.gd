@tool
extends Resource
class_name CardEffect

# Enum for Effects
enum Effects {
	Burn,
	Poison,
	Freeze,
	Stun,
	Hex,
	Paralized,
	None
}
var effectsList: String = ",".join(Effects.keys())
# Variables for properties
var effect_type: int
var delay: float
var duration_type: int
var duration: float
var damage: float
var damage_type: int
enum duration_type_list {
	Instant,
	Timed,
	Infinite
}
enum damage_type_list {
	hp_remove,
	phys,
	magic
}


func _to_string() -> String:
	return CardEffect.Effects.keys()[effect_type]


func _get_property_list() -> Array:
	var properties: Array = []

	# Effect Type
	properties.append({
		"name": "effect_type",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": effectsList
	})

	# Delay
	properties.append({
		"name": "delay",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,10,0.1,or_greater"
	})

	# Duration Type
	properties.append({
		"name": "duration_type",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Instant,Timed,Infinite"
	})

	# Duration
	properties.append({
		"name": "duration",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,60,0.5,or_greater"
	})

	# Damage
	properties.append({
		"name": "damage",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,100,1,or_greater"
	})

	# Damage Type
	properties.append({
		"name": "damage_type",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "hp_remove,phys,magic"
	})

	return properties
