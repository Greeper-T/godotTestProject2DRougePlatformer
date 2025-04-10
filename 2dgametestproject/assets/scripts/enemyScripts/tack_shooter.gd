extends CharacterBody2D

var theta: float = 0.0
@export_range(0,2*PI) var alpha: float = 0.0

const bulletNode = preload("res://assets/scenes/enemy/basic_bullet.tscn")

func getVector(angle):
	theta = angle + alpha
	return Vector2(cos(theta),sin(theta))
	
func shoot(angle):
	var bullet = bulletNode.instantiate()
	
	bullet.position = global_position
	bullet.direction = getVector(angle)
	
	get_tree().current_scene.call_deferred("add_child", bullet)

func _on_speed_timeout() -> void:
	shoot(theta)
