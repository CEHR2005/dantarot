extends Node2D

@export var CardInfo: Card = Card.new()
@export var childNode: Node2D


func _ready():
	childNode.get_resource_info(CardInfo)
