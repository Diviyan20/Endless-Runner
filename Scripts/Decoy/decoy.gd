extends Node2D

@export var move_speed: float = 0.0

func _process(delta):
	position.x += move_speed * delta
