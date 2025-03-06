extends CharacterBody2D

@export var speed: float = 400
var damage = 5

var direction: Vector2 = Vector2.ZERO

func getDamage():
	return damage

func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		position += direction * speed * delta
	


func _on_timer_timeout() -> void:
	queue_free()
