extends CharacterBody2D


@export var speed = 50
var moveDirection = Vector2.RIGHT
var surfaceNormal = Vector2.UP

func _ready() -> void:
	surfaceNormal = Vector2.UP
	moveDirection = Vector2.RIGHT
	updateRays()
	
	$rayDown.enabled = true
	$rayForward.enabled = true

func _physics_process(delta: float) -> void:
	var tangent = Vector2(-surfaceNormal.y, surfaceNormal.x).normalized()
	velocity = tangent * speed
	
	if $rayDown.is_colliding():
		var newNormal = -$rayDown.get_collision_normal()
		if newNormal != surfaceNormal:
			surfaceNormal = newNormal
			updateRays()
	else:
		if $rayForward.is_colliding():
			var newNormal = -$rayForward.get_collision_normal()
			if newNormal != surfaceNormal:
				surfaceNormal = newNormal
				updateRays()
	
	move_and_slide()
	rotation = velocity.angle()

func _draw() -> void:
	draw_line(Vector2.ZERO, $rayDown.target_position, Color.RED)
	draw_line(Vector2.ZERO, $rayForward.target_position, Color.GREEN)

func updateRays():
	$rayDown.target_position = surfaceNormal * 16
	
	var tangent = Vector2(-surfaceNormal.y, surfaceNormal.x).normalized()
	$rayForward.target_position = tangent * 16
