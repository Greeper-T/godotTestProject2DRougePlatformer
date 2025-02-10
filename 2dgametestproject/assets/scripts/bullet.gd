extends RigidBody2D

const SPEED: int = 300

func _ready() -> void:
	gravity_scale = 0
	linear_velocity = Vector2.RIGHT.rotated(rotation) * SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#position += transform.x * SPEED * delta


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
