extends Area2D




func _on_body_entered(body: Node2D) -> void:
	GameManager.add_potion()
	queue_free()
