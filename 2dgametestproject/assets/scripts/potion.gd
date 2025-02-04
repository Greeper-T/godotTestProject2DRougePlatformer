extends CollisionShape2D




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		#pick up item
		queue_free()
