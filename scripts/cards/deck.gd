extends Resource
class_name Deck

var max_size: int
@export var cards: Array[Card]


func draw():
	if Player.hand.cards.size() < 5 and Player.deck.cards.size() > 0:
		Player.hand.add_card(Player.deck.cards.pop_front())
		draw()
	else:
		pass
