extends Area2D

var speed = 100
var direction = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.takeDamage(2)
	else:
		queue_free()
