extends CharacterBody2D
class_name PlayerController

@export var speed = 3
@export var jumpPower = 10

@onready var healthBar: ProgressBar = $healthBar
@onready var animator: AnimatedSprite2D = $playerAnimator/AnimatedSprite2D

enum PlayerState { IDLE, MOVING, JUMPING, FALLING, GROUND_POUND, SPRINTING}
var currentState = PlayerState.IDLE

var speedMultiplier = 30
var jumpMultiplier = -30
var direction = 0
var jumpsLeft = 1
var sprintSpeed = speed + 3

func _input(event: InputEvent) -> void:
	#handles jumping events such as double jump and wall jumps
	if event.is_action_pressed("jump") and !Input.is_action_pressed("moveDown"):
		if is_on_floor():
			velocity.y = jumpPower * jumpMultiplier
		elif jumpsLeft >= 1:
			velocity.y = jumpPower * jumpMultiplier
			jumpsLeft -= 1
	
	#deals with healing
	if event.is_action_pressed("heal"):
		PlayerData.addHp(100)
		updateHealth()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		
		velocity += get_gravity() * delta
		if Input.is_action_pressed("moveDown") and velocity.y > 0:
			velocity.y += 40000 * delta
		if velocity.y < 0:
			currentState = PlayerState.JUMPING
		else:
			currentState = PlayerState.FALLING
	else:
		jumpsLeft = 1

	# Handle jump.
	if Input.is_action_pressed("moveDown") and Input.is_action_pressed("jump"):
		set_collision_mask_value(10,false)
	else:
		set_collision_mask_value(10,true)
	
	if Input.is_action_pressed("sprint"):
		speed = sprintSpeed
		currentState = PlayerState.SPRINTING
	else:
		speed = sprintSpeed - 3

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("moveLeft", "moveRight")
	if direction:
		velocity.x = direction * speed * speedMultiplier
		if is_on_floor():
			currentState = PlayerState.MOVING
		
	else:
		velocity.x = move_toward(velocity.x, 0, speedMultiplier * speed)
		if is_on_floor():
			currentState = PlayerState.IDLE
	
	playerAnimations()
	move_and_slide()
	
func _ready() -> void:
	updateHealth()
	GameManager.hudUpdate()

func updateHealth():
	healthBar.value = PlayerData.hp


func _on_hurtbox_body_entered(body: Node2D) -> void:
	PlayerData.takeDamage(10)
	updateHealth()

func playerAnimations():
	if currentState == PlayerState.IDLE:
		animator.play("idle")
	elif  currentState == PlayerState.MOVING:
		animator.play("move")
	elif currentState == PlayerState.JUMPING:
		animator.play("jump")
	elif currentState == PlayerState.FALLING:
		animator.play("fall")
			
			
