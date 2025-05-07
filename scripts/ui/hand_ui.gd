extends Control
@onready var h_box: HBoxContainer = %HBoxContainer

var hand: Hand = Player.hand
@export var card_scenes: Dictionary		# {CardResource : PackedScene}

func _ready() -> void:
	hand.changed.connect(_rebuild)
	_rebuild()

func _rebuild() -> void:
	# wipe old icons
	for c in h_box.get_children():
		c.queue_free()

	# create one visual per card
	for card in hand.cards:
		if card_scenes.has(card):
			var inst: Node = card_scenes[card].instantiate()
			h_box.add_child(inst)
