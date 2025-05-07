extends Resource
class_name Deck

var max_size: int
@export var cards: Array[Card]


func draw():
	return cards.pop_front()
