extends Control
@onready var health_bar: PlayerHealthBar = $HealthBar

func _on_button_pressed() -> void:
	Player.hand.cards.append(Player.deck.draw())
	print("test")
