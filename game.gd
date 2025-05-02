class_name Game
extends Node2D
@onready var player: Player = $Player
const CARD                              = preload("res://Card.tscn")
var available_cards: Array[PackedScene] = [CARD]


func _process(delta: float) -> void:
	pass


func get_player():
	return player
