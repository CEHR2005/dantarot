extends Node2D
class_name BaseUnit


@export var Hp: int


func take_damage(damage: float):
	Hp-=damage
