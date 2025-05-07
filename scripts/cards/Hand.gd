@tool
extends Resource
class_name Hand

var hand_size: int
var cards: Array[Card]

func add_card(card: Card) -> void:
	cards.push_back(card)
	emit_changed()

func remove_card_at(idx: int) -> void:
	print("remove")
	cards.remove_at(idx)
	emit_changed()

func remove_first_named(name: String) -> bool:
	for i in cards.size():
		if cards[i].cardName == name:
			remove_card_at(i)
			return true
	return false

func _get_property_list() -> Array:
	var properties: Array = []
	properties.append({
		"name": "cards",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": str("%d/%d:" + "Card") % \
			[TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE]
	})
	return properties
