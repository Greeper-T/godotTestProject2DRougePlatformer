extends CharacterBody2D

@export var speed = 3
@export var jumpPower = 10
@export var dashSpeed = 20
@export var dashTime = 0.2
@export var dashCooldown = 1.0

@onready var boss_texure: AnimatedSprite2D = $bossTexure
@onready var muzzle: Node2D = $bossTexure/muzzle


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

var hp = null
var maxHp = null
var init = false

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
		
	if event.is_action_pressed("dash") and canDash:
		startDash()


func _process(delta):
	hp = PlayerData.hp
	maxHp = PlayerData.maxHp

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
				boss_texure.scale.x = direction
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
	if init:
		maxHp = maxHp
		hp = hp
	else:
		maxHp = 100
		hp = 50
		init = true
	GameManager.hudUpdate()



func _on_hurtbox_body_entered(body: Node2D) -> void:
	var damage: float = 0
	if body.has_method("getDamage"):
		damage = body.damage
	if not isDashing:
		PlayerData.takeDamage(damage)

func takeDamage(damages: float):
	if not isDashing:
		PlayerData.takeDamage(damages)

func playerAnimations():
	if PlayerData.currentState == PlayerData.PlayerState.IDLE:
		boss_texure.play("idle")
	elif  PlayerData.currentState == PlayerData.PlayerState.MOVING:
		boss_texure.play("idle")
	elif PlayerData.currentState == PlayerData.PlayerState.JUMPING:
		boss_texure.play("idle")
	elif PlayerData.currentState == PlayerData.PlayerState.FALLING:
		boss_texure.play("idle")
