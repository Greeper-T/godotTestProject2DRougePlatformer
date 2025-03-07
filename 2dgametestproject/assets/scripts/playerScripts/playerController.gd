extends CharacterBody2D
class_name PlayerController

@export var speed = 3
@export var jumpPower = 10
@export var dashSpeed = 15
@export var dashTime = 0.2
@export var dashCooldown = 1.0
@export var afterImageNode: PackedScene

@onready var healthBar: ProgressBar = $healthBar
@onready var animator: AnimatedSprite2D = $playerAnimator/AnimatedSprite2D
@onready var gun_position: Node2D = $gunPosition
@onready var after_image_timer: Timer = $afterImageTimer

var speedMultiplier = 30
var jumpMultiplier = -30
var direction = 0
var jumpsLeft = 1
var sprintSpeed = speed + 3
var lastDirection = 1

var isDashing = false
var canDash = true
var dashTimer = 0.0
var dashCooldownTimer = 0.0

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
		
	if event.is_action_pressed("dash") and canDash:
		startDash()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		
		velocity += get_gravity() * delta
		if Input.is_action_pressed("moveDown") and velocity.y > 0:
			velocity.y += 40000 * delta
		if velocity.y < 0:
			PlayerData.currentState = PlayerData.PlayerState.JUMPING
		else:
			PlayerData.currentState = PlayerData.PlayerState.FALLING
	else:
		jumpsLeft = 1

	# Handle move down one way.
	if Input.is_action_pressed("moveDown") and Input.is_action_pressed("jump"):
		set_collision_mask_value(10,false)
	else:
		set_collision_mask_value(10,true)
	
	if Input.is_action_pressed("sprint"):
		speed = sprintSpeed
		PlayerData.currentState = PlayerData.PlayerState.SPRINTING
	else:
		speed = sprintSpeed - 3
	if isDashing:
		dashTimer -= delta
		if dashTimer <= 0:
			endDash()
	else:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
		direction = Input.get_axis("moveLeft", "moveRight")
		if direction != 0:
			velocity.x = direction * speed * speedMultiplier
			if is_on_floor():
				PlayerData.currentState = PlayerData.PlayerState.MOVING
			if direction != sign(lastDirection):
				animator.scale.x = direction
				gun_position.scale.x = direction
				lastDirection = direction
		else:
			velocity.x = move_toward(velocity.x, 0, speedMultiplier * speed)
			if is_on_floor():
				PlayerData.currentState = PlayerData.PlayerState.IDLE
	
	if not canDash:
		dashCooldownTimer -= delta
		if dashCooldownTimer <= 0:
			canDash = true
	
	playerAnimations()
	move_and_slide()
	
	
func startDash():
	isDashing = true
	canDash = false
	dashTimer = dashTime
	dashCooldownTimer = dashCooldown
	velocity.x = lastDirection * dashSpeed * speedMultiplier
	
func endDash():
	isDashing = false
	velocity.x = 0
	
func _ready() -> void:
	updateHealth()
	GameManager.hudUpdate()

func _process(delta: float) -> void:
	#update gun position
	var screen_width = get_viewport_rect().size.x
	var mouse_position = get_viewport().get_mouse_position()

	if mouse_position.x < screen_width / 2:
		gun_position.scale.x = -1  # Flip weapon to the left
	else:
		gun_position.scale.x = 1  # Flip weapon to the right

func updateHealth():
	healthBar.value = PlayerData.hp

func addAfterImage():
	var after = afterImageNode.instantiate()
	after.set_property(position, $playerAnimator/AnimatedSprite2D.scale)
	get_tree().current_scene.add_child(after)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	print("body entered")
	var damage: float = 0
	if body.has_method("getDamage"):
		damage = body.damage
	print(damage)
	if not isDashing:
		PlayerData.takeDamage(damage)
	updateHealth()

func playerAnimations():
	if PlayerData.currentState == PlayerData.PlayerState.IDLE:
		animator.play("idle")
	elif  PlayerData.currentState == PlayerData.PlayerState.MOVING:
		animator.play("move")
	elif PlayerData.currentState == PlayerData.PlayerState.JUMPING:
		animator.play("jump")
	elif PlayerData.currentState == PlayerData.PlayerState.FALLING:
		animator.play("fall")
			
			


func _on_after_image_timer_timeout() -> void:
	addAfterImage()
