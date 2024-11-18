@tool
extends Resource

class_name Card
var cardName: String
var cardArea: Shape2D
var card_effects: Array = []:
	set(value):
		card_effects = value
		notify_property_list_changed()
#enum type {
	#Self = 1 << 0, ## Specifying that the first bit in the bit array is flipped
					### resulting in an integer value of 1
	#Enemy = 1 << 1,
	#Area = 1 << 2,
#}
#var cardType: int:
	#set(value):
		#cardType = value
		#notify_property_list_changed()
#var typeKeys: Array = type.keys()
#var typeList: String = ",".join(typeKeys)

var potionsKeys: Array = TargetTypeList.keys()
## This joins the array of strings together to form one string
## with each value separated by a comma. This is the format needed by
## the hint_string
var potionsList: String = ",".join(potionsKeys)
var cardPotionBags: Array = []
var TargetType: int:
	set(value):
		TargetType = value
		notify_property_list_changed()
enum TargetTypeList {
	Self,
	Enemy,
	Area,
}

func _get_property_list() -> Array:
	var properties: Array = []
	properties.append({
		"name": "Card info",
		# More documentation here:
		# https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-variant-type
		"type": TYPE_NIL, # Categories don't have a variant type
		# More documentation here:
		# https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-propertyusageflags
		"usage": PROPERTY_USAGE_CATEGORY, # Categories do not work in tool resources,
										# but do work in standalone node scripts
		"hint_string": "card" # This must match the proceeding variable prefixes,
								# such as in the following teamName and teamColor
	})
	properties.append({
		"name": "cardName",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT, # Simple variables don't need hints
										# or hint_strings
	})
	#properties.append({
		#"name": "cardType",
		#"type": TYPE_INT,
		#"usage": PROPERTY_USAGE_DEFAULT,
		#"hint": PROPERTY_HINT_FLAGS,
		#"hint_string": typeList,
	#})
	properties.append({
		"name": "TargetType",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": potionsList,
	})
	if TargetType == TargetTypeList.Area:
		properties.append({
			"name": "cardArea",
			"type": TYPE_OBJECT,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Shape2D",
		})
	#properties.append({
		#"name": "cardEffects",
		#"type": TYPE_ARRAY,
		#"usage": PROPERTY_USAGE_DEFAULT,
		#"hint": PROPERTY_HINT_ARRAY_TYPE,
		#"hint_string": potionsList,
	#})
	properties.append({
		"name": "card_effects",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": str("%d:%d/%d:CardEffect") % \
			[TYPE_ARRAY, TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE]
	})
	#properties.append({
		#"name": "cardPotionBags",
		#"type": TYPE_ARRAY,
		#"usage": PROPERTY_USAGE_DEFAULT,
		#"hint": PROPERTY_HINT_TYPE_STRING,
		#"hint_string": str("%d:%d/%d:" + potionsList) % \
				#[TYPE_ARRAY, TYPE_INT, PROPERTY_HINT_ENUM],
	#})
	return properties

func get_target():
	print("try get target")
	pass


func activate():
	print("try activatre")
	get_target()
	
