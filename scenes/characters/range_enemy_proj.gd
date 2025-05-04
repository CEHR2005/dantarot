extends Node2D

@export var speed := 300
var direction := Vector2.ZERO

func _process(delta):
	position += direction * speed * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.take_damage(1)
	queue_free()
