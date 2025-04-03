extends Node2D

@export var start_pos: Vector2
@export var end_pos: Vector2
@export var speed: float = 50.0  # Movement speed

var direction = 1

func _process(delta):
	position += direction * (end_pos - start_pos).normalized() * speed * delta
	
	# Reverse direction when reaching the target
	if direction == 1 and position.distance_to(end_pos) < 2:
		direction = -1
	elif direction == -1 and position.distance_to(start_pos) < 2:
		direction = 1
