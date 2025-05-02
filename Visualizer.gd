@tool
extends Node2D

@export var parentNode: Node2D

var collisionShape: CollisionShape2D
var newResource: Card

@onready var card_name_label: Label = %CardName


## Be careful when running the process function in a tool script.
## If errors are written it can quickly crash the editor, fill
## the output log with errors, or slow down the editor to a crawl.
func _process(_delta) -> void:
	if Engine.is_editor_hint():
		if is_instance_valid(parentNode):
			## The variable in the parent node has to be an exported
			## variable for a tool script to be able to access it
			## if the parent's script is not a tool.
			newResource = parentNode.CardInfo
			if is_instance_valid(newResource):
				update_shape()
				update_visual()


func update_shape() -> void:
	if get_child_count() < 1:
		collisionShape = CollisionShape2D.new()
		# Be cautious when adding children via tool scripts, as
		# if done incorrectly it will overload the editor and
		# cause slowdowns and crashes.
		add_child(collisionShape)
	var newShape: Shape2D
	newShape = newResource.cardArea
	collisionShape.shape = newShape


func update_visual() -> void:
	card_name_label.text = newResource.cardName
