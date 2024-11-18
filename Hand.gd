@tool
extends Resource

class_name Hand

var hand_size: int
var cards: Array

func _get_property_list() -> Array:
	var properties: Array = []
	properties.append({
		"name": "cards",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_TYPE_STRING,
		# More examples of this are in the documentation here:
		#	https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-propertyhint
		"hint_string": str("%d/%d:" + "Card") % \
				[TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE]
	})
	return properties
