extends Node2D
@onready var player: Node2D = $Player

const CARD = preload("res://Card.tscn")
var available_cards: Array[PackedScene] = [CARD]

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("Card1"):
			print("card1")
