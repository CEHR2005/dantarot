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
}

# Variables for properties
var delay: float
var duration_type: int
enum duration_type_list { 
	Instant, 
	Timed, 
	Infinite 
}
var duration: float

var damage: float
var damage_type: int
enum damage_type_list { 
	hp_remove, 
	phys, 
	magic 
}

func _get_property_list() -> Array:
	var properties: Array = []
	properties.append({
		"name": "duration_type",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Instant,Timed,Infinite" # Fixed hint string
	})
	properties.append({
		"name": "damage_type",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "hp_remove,phys,magic" # Fixed hint string
	})
	return properties
