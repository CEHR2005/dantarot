extends Node
class_name Deck

var max_size: int
var cards: Array[Card]


func draw():
	return cards.pop_front()
