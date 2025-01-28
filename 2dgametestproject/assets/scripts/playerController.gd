extends CharacterBody2D
class_name PlayerController

@export var speed = 3
@export var jumpPower = 10

var speedMultiplier = 30
var jumpMultiplier = -30
var direction = 0
var jumpsLeft = 1
var sprintSpeed = speed + 3


#const SPEED = 300.0
#const JUMP_VELOCITY = -200.0
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor() and !Input.is_action_pressed("moveDown"):
		velocity.y = jumpPower * jumpMultiplier
	elif event.is_action_pressed("jump") and jumpsLeft >= 1 and !Input.is_action_pressed("moveDown"):
		velocity.y = jumpPower * jumpMultiplier
		jumpsLeft -= 1
	
	


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumpsLeft = 1

	# Handle jump.
	if Input.is_action_pressed("moveDown") and Input.is_action_pressed("jump"):
		set_collision_mask_value(10,false)
	else:
		set_collision_mask_value(10,true)
	
	if Input.is_action_pressed("sprint"):
		speed = sprintSpeed
	else:
		speed = sprintSpeed - 3

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("moveLeft", "moveRight")
	if direction:
		velocity.x = direction * speed * speedMultiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speedMultiplier * speed)

	move_and_slide()
