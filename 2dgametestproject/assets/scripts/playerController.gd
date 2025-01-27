extends CharacterBody2D
class_name PlayerController

@export var speed = 10
@export var jumpPower = 10

var speedMultiplier = 30
var jumpMultiplier = -30
var direction = 0


#const SPEED = 300.0
#const JUMP_VELOCITY = -200.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpPower * jumpMultiplier

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("moveLeft", "moveRight")
	if direction:
		velocity.x = direction * speed * speedMultiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speedMultiplier * speed)

	move_and_slide()
