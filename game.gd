extends Node2D
@onready var player: Node2D = $Player

const CARD = preload("res://Card.tscn")
var available_cards: Array[PackedScene] = [CARD]

func _process(delta: float) -> void:
	pass
