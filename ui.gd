extends Control

func _on_button_pressed() -> void:
	var game: Game     = get_parent()
	var player: Player = game.get_player()
	player.hand.cards.append(player.deck.draw())
	print("test")
