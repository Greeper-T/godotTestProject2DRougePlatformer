extends CharacterBody2D


@export var speed = 50
var moveDirection = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	update_direction()
	var tangent = Vector2(moveDirection.y, -moveDirection.x)  # 90° rotation
	velocity = tangent * speed
	rotation = moveDirection.angle()
	move_and_slide()
	
func update_direction():
	if $rayCasts/rayDown.is_colliding():
		moveDirection = Vector2.DOWN
	elif $rayCasts/rayRight.is_colliding():
		moveDirection = Vector2.RIGHT
	elif $rayCasts/rayUp.is_colliding():
		moveDirection = Vector2.UP
	elif $rayCasts/rayLeft.is_colliding():
		moveDirection = Vector2.LEFT
