extends Node2D
## Made by LeifInTheWind 13-Aug-24
## This is a companion project for the advanced exports tutorial on
## youtube by https://www.youtube.com/@Leif_in_the_Wind

@export var CardInfo: Card = Card.new()

@export var childNode: Node2D

func _ready():
	childNode.get_resource_info(CardInfo)
